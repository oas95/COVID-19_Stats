/*

Cleaning Data in SQL Queries

Standardizing Date, Property address population, Removing Duplicates, Deleting Unused Columns

*/


Select *
From PortfolioProjects..NashvilleHousing_v1

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format


Select saleDateConverted, CONVERT(Date,SaleDate)
From PortfolioProjects..NashvilleHousing_v1


Update NashvilleHousing_v1
SET SaleDate = CONVERT(Date,SaleDate)

-- If it doesn't Update properly

ALTER TABLE NashvilleHousing_v1
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)


 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select *
From PortfolioProjects..NashvilleHousing_v1
--Where PropertyAddress is null
order by ParcelID



Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProjects..NashvilleHousing_v1 a
JOIN PortfolioProjects..NashvilleHousing_v1 b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProjects..NashvilleHousing_v1 a
JOIN PortfolioProjects..NashvilleHousing_v1 b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null




--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress
From From PortfolioProjects..NashvilleHousing_v1
--Where PropertyAddress is null
--order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

From From PortfolioProjects..NashvilleHousing_v1


ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing_v1
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE NashvilleHousing_v1
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing_v1
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))




Select *
From PortfolioProjects..NashvilleHousing_v1





Select OwnerAddress
From PortfolioProjects..NashvilleHousing_v1


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From PortfolioProjects..NashvilleHousing_v1



ALTER TABLE NashvilleHousing_v1
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing_v1
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleHousing_v1
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing_v1
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE NashvilleHousing_v1
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing_v1
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



Select *
From PortfolioProjects..NashvilleHousing_v1




--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProjects..NashvilleHousing_v1
Group by SoldAsVacant
order by 2




Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From PortfolioProjects..NashvilleHousing_v1


Update NashvilleHousing_v1
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END






-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProjects..NashvilleHousing_v1
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



Select *
From PortfolioProjects..NashvilleHousing_v1




---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns



Select *
From PortfolioProjects..NashvilleHousing_v1


ALTER TABLE PortfolioProjects..NashvilleHousing_v1
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate















-----------------------------------------------------------------------------------------------