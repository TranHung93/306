# Create project's folder based on pre-defined folder structure

A generic function to create a project's folder based on pre-defined
folder structure.

## Usage

``` r
createProject(dir, structure = c("OUCRU_RCT_wInterim"))
```

## Arguments

- dir:

  a character specifies where to create the project's folder. It must
  not exist yet, or be an empty folder.

- structure:

  a character specifies the pre-defined folder structure to be used.

## Value

The path of the created project folder, invisibly. A message confirms
where the project was created.

## Examples

``` r
proj <- file.path(tempdir(), "myStudy")
createProject(proj)
#> Project myStudy was created in /tmp/RtmpPbSqhg
list.files(proj)
#> [1] "Analysis"        "Data"            "Documents"       "InterimAnalysis"
#> [5] "myStudy.Rproj"  
unlink(proj, recursive = TRUE)
```
