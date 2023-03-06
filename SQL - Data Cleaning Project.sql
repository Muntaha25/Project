--*/ Cleaning data in sql 


select *
from dbo.HousingProject

--standardize data format



--it couldn't work

select SaleDate, convert(date, saledate)
from dbo.HousingProject


--it worked
alter table housingproject
add saledateconverted date

update HousingProject
set SaleDateconverted = convert(date, saledate) 



--populate property address 



select a.[UniqueID ] ,a.ParcelID,a.PropertyAddress, b.[UniqueID ], b.ParcelID, b.PropertyAddress, ISNULL (a.propertyaddress, b.PropertyAddress) as NotNullPropertyAdd
from dbo.HousingProject a
join dbo.HousingProject b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]!=b.[UniqueID ]
where a.PropertyAddress is null
order by a.ParcelID

update a
set a.propertyaddress = ISNULL (a.propertyaddress, b.PropertyAddress)
from dbo.HousingProject a
join dbo.HousingProject b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]!=b.[UniqueID ]
where a.PropertyAddress is null



--to check


select *
from dbo.HousingProject
where PropertyAddress is null



--breaking address into separate columns



select PropertyAddress
from dbo.HousingProject

select 
SUBSTRING(propertyaddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(propertyaddress, CHARINDEX(',', PropertyAddress) +1, len(propertyaddress)) as Address

from dbo.HousingProject

alter table housingproject
add propertysplitAdd nvarchar(255)

update HousingProject
set propertysplitAdd = SUBSTRING(propertyaddress, 1, CHARINDEX(',', PropertyAddress) -1)

alter table housingproject
add propertysplitCit nvarchar(255)

update HousingProject
set propertysplitcit = SUBSTRING(propertyaddress, CHARINDEX(',', PropertyAddress) +1, len(propertyaddress))

--Let's Split owneraddress

select owneraddress
from dbo.HousingProject


--another method to split the columns in a table without the help of 'subtring function'

select 
PARSENAME(replace(OwnerAddress, ',', '.'), 3), 
PARSENAME(replace(OwnerAddress, ',', '.'), 2), 
PARSENAME(replace(OwnerAddress, ',', '.'), 1) 
from dbo.housingproject


alter table housingproject
add ownerstreetAdd nvarchar(255)

update HousingProject
set ownerstreetAdd = PARSENAME(replace(OwnerAddress, ',', '.'), 3) 


alter table housingproject
add OwnercityAdd nvarchar(255)

update HousingProject
set ownercityadd = PARSENAME(replace(OwnerAddress, ',', '.'), 2)

alter table housingproject
add Ownerstateadd nvarchar(255)

update HousingProject
set ownerstateadd = PARSENAME(replace(OwnerAddress, ',', '.'), 1)




select distinct(soldasvacant), count(soldasvacant)
from dbo.HousingProject
group by SoldAsVacant
order by 2

select soldasvacant
, case when soldasvacant = 'y' then 'yes'
 when soldasvacant = 'n' then 'no'
else soldasvacant
end
from dbo.HousingProject

update dbo.HousingProject
set SoldAsVacant = case when soldasvacant = 'y' then 'yes'
 when soldasvacant = 'n' then 'no'
else soldasvacant
end
  
--To Check

select SoldAsVacant
from dbo.HousingProject
 

 --removing duplicates

 select *,
 ROW_NUMBER () over ( partition by parcelid,
 propertyaddress, saleprice, saledate, legalreference order by uniqueid)row_num

 from dbo.HousingProject
 order by parcelid

 with rownumcte as ( 
 select *,
 ROW_NUMBER () over ( partition by parcelid,
 propertyaddress, saleprice, saledate, legalreference order by uniqueid)row_num

 from dbo.HousingProject)
 select*
 from rownumcte 
 where row_num > 1
 order by parcelid



 --to delete duplicates
 
 
 delete 
 from rownumcte 
 where row_num > 2
 --order by parcelid

 
 
 --to check 

 with rownumcte as ( 
 select *,
 ROW_NUMBER () over ( partition by parcelid,
 propertyaddress, saleprice, saledate, legalreference order by uniqueid)row_num

 from dbo.HousingProject)
 select*
 from rownumcte 
 where row_num > 2
 order by parcelid
 
 --delete unused columns

 select *
 from dbo.HousingProject

 alter table dbo.housingproject
 drop column owneraddress, taxdistrict, propertyaddress, saledate