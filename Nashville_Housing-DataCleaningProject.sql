/* I tried doing a Data Cleaning Project on SQL, So I downloaded Nashville City data from Kaggle and then performed some basic data cleaning. Open to feedback*/
--Updating the Date Column
SELECT SaleDate, CONVERT(Date, SaleDate)
FROM PortfolioProjects..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD SaleDateNew date

Update NashvilleHousing
SET SaleDateNew =  CONVERT(Date, SaleDate)

--Populate Property Address
/*We figured out that in some cases there are NULL value. We saw a pattern that, Parcel ID is getting repeated and 
it has same property addresses. So we can copy the address from one parcel id to the other same id where address is null*/

SELECT a.ParcelID,a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProjects..NashvilleHousing a
JOIN PortfolioProjects..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
--WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProjects..NashvilleHousing a
JOIN PortfolioProjects..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

--Breaking out Address into Individual Columns

Select SUBSTRING(PropertyAddress, 1, (CHARINDEX(',',PropertyAddress)-1)) as Address,
SUBSTRING(PropertyAddress,(CHARINDEX(',',PropertyAddress)+1),Len(PropertyAddress)) as City
From PortfolioProjects..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, (CHARINDEX(',',PropertyAddress)-1))

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitCity= SUBSTRING(PropertyAddress,(CHARINDEX(',',PropertyAddress)+1),Len(PropertyAddress))

--We can also use PARSENAME to split up the address but for that we need to replace , with .
Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From PortfolioProjects..NashvilleHousing

Select *
From PortfolioProjects..NashvilleHousing

ALTER TABLE PortfolioProjects..NashvilleHousing
Add OnwerSplitAddress Nvarchar(255)

UPDATE PortfolioProjects..NashvilleHousing
SET OnwerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE PortfolioProjects..NashvilleHousing
Add OwnerSplitCity Nvarchar(255)

UPDATE PortfolioProjects..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE PortfolioProjects..NashvilleHousing
Add OwnerSplitState Nvarchar(255)

UPDATE PortfolioProjects..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

SELECT *
FROM PortfolioProjects..NashvilleHousing
ALTER TABLE PortfolioProjects..NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

--Change Y and N to Yes and No in "Sold as Vacant" Field
SELECT Distinct(SoldAsVacant),Count(SoldAsVacant)
FROM PortfolioProjects..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant ='Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM PortfolioProjects..NashvilleHousing

UPDATE PortfolioProjects..NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant ='Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END

--Remove Duplicated Rows
With RowNumCTE AS(
Select *,
--ROW_Number() function is used to number rows. When used with OVER(PARTION BY) it will number a certain amount of rows and then the counter will again start from 1 when a partition by clause is encountered.	
	Row_Number() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					)row_num
			
FROM PortfolioProjects..NashvilleHousing
)
DELETE
FROM RowNumCTE
where row_num>1

--DELETE Unused Columns
ALTER TABLE PortfolioProjects..NashvilleHousing
DROP COLUMN PropertyAddress, SaleDate, OwnerAddress, SaleDateConverted --I mistakenly created two columns doing the same thing

Select * 
FROM PortfolioProjects..NashvilleHousing
