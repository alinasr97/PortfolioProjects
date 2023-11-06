
--Cleanind Data in SQL Queries

Select * 
from portfolioproject..NasvilleHousing
order by 2


-----------------------------------------------------------------
--Standardize Date Format
ALTER TABLE NasvilleHousing
ADD SaleDateConverted Date;

update NasvilleHousing
set SaleDateConverted = convert(Date,SaleDate)

select SaleDateConverted
from portfolioproject..NasvilleHousing


---------------------------------------------------------------
--Populate Property Address Data
select *
from portfolioproject..NasvilleHousing
--where PropertyAddress is null
order by ParcelID


update TableA
SET PropertyAddress = ISNULL (TableA.PropertyAddress , TableB.PropertyAddress)
from portfolioproject..NasvilleHousing TableA
JOIN portfolioproject..NasvilleHousing TableB
	on TableA.ParcelID = TableB.ParcelID
	AND TableA.[UniqueID ] <> TableB.[UniqueID ]
where TableA.PropertyAddress IS NULL

Select TableA.ParcelID, TableA.PropertyAddress, TableB.ParcelID, TableB.PropertyAddress , ISNULL(TableA.PropertyAddress,TableB.PropertyAddress)
from portfolioproject..NasvilleHousing TableA
JOIN portfolioproject..NasvilleHousing TableB
	ON TableA.ParcelID = TableB.ParcelID
	AND TableA.[UniqueID ] <> TableB.[UniqueID ]
where TableA.PropertyAddress is null


---------------------------------------------------------------
--Breaking out adress into individual coulmns (adress, city, state)
select PropertyAddress
from portfolioproject..NasvilleHousing

--select
--PARSENAME(Replace(PropertyAddress, ',', '.'), 2) as address
--,PARSENAME(Replace(PropertyAddress, ',', '.'), 1) as city
--from portfolioproject..NasvilleHousing

select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) AS City
from portfolioproject..NasvilleHousing

ALTER TABLE NasvilleHousing
ADD PropertySplitAddress nvarchar(255);

update NasvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NasvilleHousing
ADD PropertySplitCity nvarchar(255);

update NasvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) 

select *
from portfolioproject..NasvilleHousing




select OwnerAddress
from portfolioproject..NasvilleHousing

select
PARSENAME(Replace(OwnerAddress, ',', '.'), 3) as address
,PARSENAME(Replace(OwnerAddress, ',', '.'), 2) as city
,PARSENAME(Replace(OwnerAddress, ',', '.'), 1) as state
from portfolioproject..NasvilleHousing

ALTER TABLE NasvilleHousing
ADD OwnerSplitAddress nvarchar(255);

update NasvilleHousing
set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.'), 3)

ALTER TABLE NasvilleHousing
ADD OwnerSplitCity nvarchar(255);

update NasvilleHousing
set OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',', '.'), 2)

ALTER TABLE NasvilleHousing
ADD OwnerSplitState nvarchar(255);

update NasvilleHousing
set OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',', '.'), 1)

select *
from portfolioproject..NasvilleHousing


----------------------------------------------------------------------------

--change Y and N to Yes and No in "Sold as Vacant" Field

Select Distinct(SoldAsVacant), count (SoldAsVacant)
from portfolioproject..NasvilleHousing
Group by SoldAsVacant
order by 2

Select SoldAsVacant , CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
							WHEN SoldAsVacant = 'N' THEN 'No'
							Else SoldAsVacant
							END
from portfolioproject..NasvilleHousing

UPDATE NasvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
							WHEN SoldAsVacant = 'N' THEN 'No'
							Else SoldAsVacant
							END

Select Distinct(SoldAsVacant), count (SoldAsVacant)
from portfolioproject..NasvilleHousing
Group by SoldAsVacant
order by 2



-------------------------------------------------------------------------

--Remove Duplicates
WITH RowNumCTE AS(
select * , ROW_NUMBER() OVER (PARTITION BY  ParcelID,
											PropertyAddress,
											SalePrice,
											SaleDate,
											LegalReference
											ORDER BY UniqueID 
											)row_num

from portfolioproject..NasvilleHousing
)
Delete
FROM RowNumCTE
Where row_num > 1
Order by PropertyAddress

select *
FROM RowNumCTE
Where row_num > 1
Order by PropertyAddress