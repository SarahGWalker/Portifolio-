--Cleaning Data in SQL Queries 

Select * 
From PortfolioProject.dbo.NashvilleHousing


-----------------------------------------------------------------------------------

--Standardize Date Format

Select SaleDate, CONVERT(Date,SaleDate)
From PortfolioProject.dbo.NashvilleHousing

Update PortfolioProject.dbo.NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALter Table PortfolioProject.dbo.NashvilleHousing
Add  SaleDateConverted Date;

Update PortfolioProject.dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

-----------------------------------------------------------------------------------

--Populate Property Address Data

Select *
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null 
order by ParcelID

--We found address that were null, 
--We found ParcelIDs that had duplicate addresses 


Select a.ParcelID, b.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(b.PropertyAddress, a.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a 
JOIN PortfolioProject.dbo.NashvilleHousing b
     on a.ParcelID = b.ParcelID
	 AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null 

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a 
JOIN PortfolioProject.dbo.NashvilleHousing b
     on a.ParcelID = b.ParcelID
	 AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--Breaking out address into individual Colums (Address, City, States) 

Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null 
--order by ParcelID

--The comma is being used to separate the street and city. So we're going to use a substring to seperate them out.

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address , 
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address 
From PortfolioProject.dbo.NashvilleHousing

--Creating two new columns and add that value in

ALter Table PortfolioProject.dbo.NashvilleHousing
Add PropertySplitAddress1 Varchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET PropertySplitAddress1 = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALter Table PortfolioProject.dbo.NashvilleHousing
ADD PropertySplitCity Varchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

--ALTER TABLE PortfolioProject.dbo.NashvilleHousing
--DROP COLUMN PropertySplitAddress;

Select *
From PortfolioProject.dbo.NashvilleHousing



--We have the address the city and the state. We need to separate them all out and make new columns. 
--this time instead of substring, I'm going to use PARSENAME

Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing

Select 
PARSENAME(REPLACE(Owneraddress, ',' , '.') , 3), 
PARSENAME(REPLACE(Owneraddress, ',' , '.') , 2), 
PARSENAME(REPLACE(Owneraddress, ',' , '.') , 1) 
From PortfolioProject.dbo.NashvilleHousing


ALter Table PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitAddress Varchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(Owneraddress, ',' , '.') , 3)


ALter Table PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitCity Varchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(Owneraddress, ',' , '.') , 2)

ALter Table PortfolioProject.dbo.NashvilleHousing
ADD OwnerSplitState Varchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(Owneraddress, ',' , '.') , 1)


Select *
From PortfolioProject.dbo.NashvilleHousing

------------------------------------------------------------------------------------------------------------------------------------

--Change Y and N to Yes and No in 'Sold as Vacant" field 

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant
, Case when SoldAsVacant = 'Y' THEN 'Yes'
       when SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant 
	   END
From PortfolioProject.dbo.NashvilleHousing

Update PortfolioProject.dbo.NashvilleHousing
SET SoldAsVacant = Case when SoldAsVacant = 'Y' THEN 'Yes'
       when SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant 
	   END


------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates 
--Don't do this to raw data

WITH RowNumCTE AS(
Select *,
   Row_number() Over (  
   PARTITION BY ParcelID,
                PropertyAddress,			
				SalePrice,	
				SaleDate,
				LegalReference
				ORDER BY 
				UniqueID)
				row_num

From PortfolioProject.dbo.NashvilleHousing
--Order by ParcelID
)
--DELETE
Select*
From RowNumCTE 
where row_num > 1
Order by PropertyAddress


------------------------------------------------------------------------------------------------------------------------------------------
--Delete unused columns
--Don't do this to raw data

Select *
From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress 

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN PropertySplitAddress1

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN PropertySplitCity

Select *
From PortfolioProject.dbo.NashvilleHousing