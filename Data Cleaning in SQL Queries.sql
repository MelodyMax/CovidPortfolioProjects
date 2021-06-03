-- CLEANING DATA IN SQL QUERIES

Select *
From PortfolioProject..NashvilleHousing

-- Standardized Date Format (Converting SaleDate column to Date Format)

Select SaleDate, CONVERT(Date, SaleDate)
From PortfolioProject..NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

/*(My Update says successfully completed but didn't actually make changes on table,
probably because there's an instead of trigger that skips the Update) */

-- I'll use the Alter Table to update my SaleDate

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

Select SaleDateConverted
From PortfolioProject..NashvilleHousing

-- Populate Property Address Data

Select *
From PortfolioProject..NashvilleHousing
Where PropertyAddress is null

-- The data shows that ParcelId corresponds to a Property Address
-- We can use self join to match the ParcelId and Property Address

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
From PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-- Let's actually start populating all Nulls in a.PropertyAddress with address in b.PropertyAddress

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--With Join in an Update statement, I need to specify which alias to use to avoid error

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-- Breaking up PropertyAddress into Individual Columns (Street, City) using SUBSTRING

Select PropertyAddress
From PortfolioProject..NashvilleHousing

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1),
 --CHARINDEX(',', PropertyAddress),
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 ,LEN(PropertyAddress))
From PortfolioProject..NashvilleHousing

/* -Adding the two new address columns to the table 
   -In order to create two values from one column (street and city address), 
   I needed to create two other columns (PropertySplitStreet and PropertySplitCity)
*/

ALTER TABLE NashvilleHousing
Add PropertySplitStreet Nvarchar(255)

Update NashvilleHousing
SET PropertySplitStreet = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255)

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 ,LEN(PropertyAddress))


-- Now, let's break up OwnerAddress into Individual Columns (Street, City, State) using PARSENAME

Select OwnerAddress
From PortfolioProject..NashvilleHousing

-- With PARSENAME, you can only use a period as the delimiter to split on.
-- I replaced the comma with a period.

Select 
PARSENAME(REPLACE(OwnerAddress,',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress,',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress,',', '.'), 1)
From PortfolioProject..NashvilleHousing

-- Adding the 3 new columns to the table

ALTER TABLE NashvilleHousing
Add OwnerSplitStreet Nvarchar(255)

Update NashvilleHousing
SET OwnerSplitStreet = PARSENAME(REPLACE(OwnerAddress,',', '.'), 3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255)

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',', '.'), 2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255)

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',', '.'), 1)

-- Checking if all the columns were properly added

Select *
From PortfolioProject..NashvilleHousing

-- Change Y and N to Yes or No in "Sold as Vacant" Field

Select Distinct(SoldAsVacant), Count(SoldASVacant)
From PortfolioProject..NashvilleHousing
Group by SoldAsVacant
Order by 2 desc

-- Using a case statement

Select SoldAsVacant,
CASE 
	When SoldAsVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' THEN 'No'
	Else SoldAsVacant
END
From PortfolioProject..NashvilleHousing

-- Updating the table with the changes I made

Update NashvilleHousing
SET SoldAsVacant = CASE 
	When SoldAsVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' THEN 'No'
	Else SoldAsVacant
END

-- Figuring out Duplicates using ROW_NUM and CTE

WITH RowNumCTE AS (
Select *, 
	ROW_NUMBER () OVER (
	PARTITION BY ParcelID,
				 PropertyAddress, 
				 SalePrice,
				 SaleDate,
				 LegalReference
	ORDER BY UniqueID) row_num

From PortfolioProject..NashvilleHousing
)

Select *
From RowNumCTE
WHERE row_num >1
Order by PropertyAddress

-- Removing Duplicates from the table

WITH RowNumCTE AS (
Select *, 
	ROW_NUMBER () OVER (
	PARTITION BY ParcelID,
				 PropertyAddress, 
				 SalePrice,
				 SaleDate,
				 LegalReference
	ORDER BY UniqueID) row_num

From PortfolioProject..NashvilleHousing
)

DELETE
From RowNumCTE
WHERE row_num >1

-- Deleting Unused Columns

Select *
From PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict, SaleDate


