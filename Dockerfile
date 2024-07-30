# Use the R base image
FROM rocker/r-ver:4.1.0

# Install required R packages
RUN R -e "install.packages(c('plumber', 'randomForest', 'caret', 'ranger', 'tidyverse'), repos='http://cran.rstudio.com/')"

# Copy the model API script
COPY model_api.R /model_api.R

# Expose the API port
EXPOSE 8000

# Run the API
CMD ["R", "-e", "pr <- plumber::plumb('/model_api.R'); pr$run(host='0.0.0.0', port=8000)"]
