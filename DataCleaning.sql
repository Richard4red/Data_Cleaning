Select *
From PortfolioProject2..HouseData

-- Standartize Date Format
Select SaleDateConverted, CONVERT(Date, SaleDate)
From PortfolioProject2..HouseData

Update PortfolioProject2..HouseData
Set SaleDate = CONVERT(Date, SaleDate)

Alter Table HouseData
Add SaleDateConverted Date;

Update PortfolioProject2..HouseData
Set SaleDateConverted = CONVERT(Date, SaleDate)

-------------------------------------------------------
-- Fixing Missing PropertyAddress
Select *
From PortfolioProject2..HouseData
Where PropertyAddress is Null


Select ID.ParcelID,Prop.ParcelID,Id.PropertyAddress , Prop.PropertyAddress, ISNULL(Prop.PropertyAddress, Id.PropertyAddress)
From PortfolioProject2..HouseData Prop
Join PortfolioProject2..HouseData Id
on Prop.ParcelID = Id.ParcelID
And Prop.[UniqueID ] <> Id.[UniqueID ]
Where Prop.PropertyAddress is Null

Update Prop
Set Prop.PropertyAddress = ISNULL(Prop.PropertyAddress, Id.PropertyAddress)
From PortfolioProject2..HouseData Prop
Join PortfolioProject2..HouseData Id
on Prop.ParcelID = Id.ParcelID
And Prop.[UniqueID ] <> Id.[UniqueID ]
Where Prop.PropertyAddress is Null

--------------------------------------------------------
-- Breaking Address into (Address, City, State)

Select PropertyAddress
From PortfolioProject2..HouseData

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, Len(PropertyAddress)) as City
From PortfolioProject2..HouseData

Alter Table HouseData
Add  PropertySplitAddress	Nvarchar(255);

Update PortfolioProject2..HouseData
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1)

Alter Table HouseData
Add  PropertySplitCity	Nvarchar(255);

Update PortfolioProject2..HouseData
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, Len(PropertyAddress)) 


Select PropertyAddress, PropertySplitAddress, PropertySplitCity
From PortfolioProject2..HouseData

Select OwnerAddress
From PortfolioProject2..HouseData

Select 
ParseName(Replace(OwnerAddress,',','.'), 3),
ParseName(Replace(OwnerAddress,',','.'), 2),
ParseName(Replace(OwnerAddress,',','.'), 1)
From PortfolioProject2..HouseData



Alter Table HouseData
Add  OwnerSplitAddress	Nvarchar(255);

Update PortfolioProject2..HouseData
Set OwnerSplitAddress = ParseName(Replace(OwnerAddress,',','.'), 3)

Alter Table HouseData
Add  OwnerSplitCity	Nvarchar(255);

Update PortfolioProject2..HouseData
Set OwnerSplitCity = ParseName(Replace(OwnerAddress,',','.'), 2)

Alter Table HouseData
Add  OwnerSplitState	Nvarchar(255);

Update PortfolioProject2..HouseData
Set OwnerSplitState = ParseName(Replace(OwnerAddress,',','.'), 1)

Select * 
From PortfolioProject2..HouseData

----------------------------------------------------------------------

--Fixing SoldAsVacant Replacing y,n to Yes,No

Select Distinct(SoldAsVacant), Count(SoldAsVacant) Count
From PortfolioProject2..HouseData
Group by SoldAsVacant
order by 2

Select 
Case 
	When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant
	End
From PortfolioProject2..HouseData

Update PortfolioProject2..HouseData
Set SoldAsVacant = Case 
	When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant
	End

--------------------------------------------------------

--Remove Duplicates

	With RowNumCTE AS (
Select *, ROW_NUMBER() Over(Partition by  ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference Order By UniqueID) Row_NUM
From PortfolioProject2..HouseData
)
Delete 
From RowNumCTE
Where Row_NUM > 1

	With RowNumCTEcheck AS (
Select *, ROW_NUMBER() Over(Partition by  ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference Order By UniqueID) Row_NUM
From PortfolioProject2..HouseData
)
select * 
From RowNumCTEcheck
Where Row_NUM > 1


---------------------------------------------------------------

--Delete Unused Columns

Select *
From PortfolioProject2..HouseData

Alter Table  PortfolioProject2..HouseData
Drop Column PropertyAddress, OwnerAddress, TaxDistrict

Alter Table  PortfolioProject2..HouseData
Drop Column SaleDate

Select *
From PortfolioProject2..HouseData
