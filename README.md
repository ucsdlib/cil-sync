### CIL Harvesting
This repository will download the source JSON files and content files for CIL harvesting from the github repository CIL_Public_Data_JSON. And the JSON source files will be converted to CSV format and stored in dams-staging.

##### Set up and run
###### Clone CIL_Public_Data_JSON
`git clone git@github.com:slash-segmentation/CIL_Public_Data_JSON.git`

###### Clone CIL-Sync repository
`git clone https://github.com/ucsdlib/cil-sync.git`

###### Run the script
```
cd cil-sync
chmod 755 ./git_changes.sh
./git_changes.sh /path/to/CIL_Public_Data_JSON /pub/data2/damsmanager/dams-staging/rdcp-staging/rdcp-0126-cil
```

##### Files location
JSON Source files
`dams-staging/rdcp-staging/rdcp-0126-cil/cil_harvest_[YYYY-MM-DD]/metadata_source`

Content files
`dams-staging/rdcp-staging/rdcp-0126-cil/cil_harvest_[YYYY-MM-DD]/content_files`

Processed files (CSV)
`dams-staging/rdcp-staging/rdcp-0126-cil/cil_harvest_[YYYY-MM-DD]/metadata_processed`

