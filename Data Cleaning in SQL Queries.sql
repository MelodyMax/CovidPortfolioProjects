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

-- Breaking up Address into Individual Columns (Street, City, State) using SUBSTRING

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
Add  PropertySplitCity Nvarchar(255)

-- Checking if the columns are properly added

Select *
From PortfolioProject..NashvilleHousing


