#!/bin/Rscript
# Run latex, run bibtex, run latex, and display dvi.
library(knitr)

root <- "~"
resource_root <- "~/output_store"
project_path <- "projekty/dengue-dynamics"
resource_dir <- file.path(resource_root, project_path)

input_dir <- file.path(root,project_path,"generator-scripts")
tex_dir <- file.path(root,project_path,"tex")
R_dir <- file.path(root,project_path,"R")

figure_dir <- file.path(root,project_path,"figures")

generated_sections <- dir(path=file.path(input_dir), pattern="\\.Rnw")
generated_sections <- mapply(substr, x=generated_sections,
														 stop=sapply(generated_sections,nchar)-4,
														 MoreArgs=list(start=1))

pocket <- new.env()

make_R <- function() {
	for ( i in seq_along(generated_sections)) {
		knit(
			input=file.path(input_dir,paste0(generated_sections[i],".Rnw")),	
			output=file.path(R_dir, paste0(generated_sections[i],".R")),
			tangle=TRUE, envir=pocket)
	}
}

make_tex <- function() {
	for ( i in seq_along(generated_sections)) {
		knit(
			input=file.path(input_dir,paste0(generated_sections[i],".Rnw")),	
			output=file.path(tex_dir, paste0(generated_sections[i],".tex")),
			envir=pocket)
	}
}



