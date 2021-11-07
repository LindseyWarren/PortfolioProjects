/* 
Data Cleaning in SQL
*/


Select * 
From PortfolioProject..NashvilleHousing

--Standardize date format

Select SaleDate, Convert(Date,SaleDate)
From PortfolioProject..NashvilleHousing

Update NashvilleHousing
Set SaleDate = CONVERT(Date, SaleDate)

Alter Table NashvilleHousing 
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = Convert(Date, SaleDate)

Select SaleDateConverted, Convert(Date,SaleDate)
From PortfolioProject..NashvilleHousing

-- Populate Property Address
Select *
From PortfolioProject..NashvilleHousing
--Where PropertyAddress is null
order by ParcelID


Select orig.ParcelID, orig.PropertyAddress, new.ParcelID, new.PropertyAddress, ISNULL(orig.PropertyAddress, new.PropertyAddress)
From PortfolioProject..NashvilleHousing orig
Join PortfolioProject..NashvilleHousing new
	on orig.ParcelID = new.ParcelID
	and orig.[UniqueID ] <> new.[UniqueID ]
Where orig.PropertyAddress is null

UPDATE orig
SET PropertyAddress = ISNULL(orig.PropertyAddress, new.PropertyAddress)
From PortfolioProject..NashvilleHousing orig
Join PortfolioProject..NashvilleHousing new
	on orig.ParcelID = new.ParcelID
Where orig.PropertyAddress is null	and orig.[UniqueID ] <> new.[UniqueID ]






---Break out address into individual columns (Address, City, State)

Select PropertyAddress
From PortfolioProject..NashvilleHousing


Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress)) as Address
From PortfolioProject..NashvilleHousing

Alter Table NashvilleHousing 
Add PropertySplitAddress nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

Alter Table NashvilleHousing 
Add PropertySplitCity  nvarchar(255);

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress))

Select *
From PortfolioProject..NashvilleHousing



--


Select OwnerAddress
From PortfolioProject..NashvilleHousing

Select 
PARSENAME(replace(OwnerAddress, ',', '.'), 3),
PARSENAME(replace(OwnerAddress, ',', '.'), 2),
PARSENAME(replace(OwnerAddress, ',', '.'), 1)
From PortfolioProject..NashvilleHousing





Alter Table NashvilleHousing 
Add OwnerSplitAddress nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(replace(OwnerAddress, ',', '.'), 3)

Alter Table NashvilleHousing 
Add OwnerSplitCity  nvarchar(255);

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(replace(OwnerAddress, ',', '.'), 2)

Alter Table NashvilleHousing 
Add OwnerSplitState  nvarchar(255);

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(replace(OwnerAddress, ',', '.'), 1)


---- Change Y and N to Yes and No in Sold as Vacant field

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From PortfolioProject..NashvilleHousing
Group by SoldAsVacant
order by 2

Select SoldAsVacant,
Case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end
From PortfolioProject..NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = Case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end


---Remove Duplicates

WITH RowNUMCTE AS (
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					)row_num
From PortfolioProject..NashvilleHousing
--order by ParcelID
)
--Select *
Delete
From RowNUMCTE
Where row_num > 1
--order by PropertyAddress

-- Delete Unused columns

Select * 
From PortfolioProject..NashvilleHousing

Alter Table PortfolioProject..NashvilleHousing
Drop column OwnerAddress, PropertyAddress, TaxDistrict, SaleDate


