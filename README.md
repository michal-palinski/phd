# PhD Project Repository: The Data Calculus: How Consumers Value Their Personal Data?

This repository contains the main data and scripts used in the empirical analyses conducted for my PhD project in Economics at the University of Warsaw.

As a strong proponent of open science, I have made all anonymized stated preference datasets and the corresponding code publicly available. This initiative is intended to promote transparency, ensure reproducibility, and serve as a practical resource for researchers working on privacy preference elicitation, discrete choice experiments (DCEs), and related topics. By sharing both data and methodological tools, I aim to support future research, encourage collaboration, and contribute to the wider dissemination of empirical techniques in the context of the digital economy.

## Structure

The repository is organized into folders corresponding to the main empirical analyses of the thesis:

### Chapter 1 – Topic Modelling of Economics of Privacy Literature
Contains topic modelling results from a corpus of academic papers on privacy, retrieved from Scopus and Web of Science. Each paper is assigned to a specific topic, allowing further analysis of the privacy literature from different thematic angles.

### Chapter 3 – Ex ante welfare assessment of the General Data Protection Regulation
Includes data from the stated preference experiment by Sobolewski & Palinski (2017), focused on users' willingness to pay for GDPR-compliant mechanisms. While initially analyzed using `mlogit` in R, the models have been recalculated here using the more flexible and powerful `apollo` package. The code allows for the estimation of a basic Mixed Logit (MXL) model.

### Chapter 4 – Chapter 4	Paying with your data. Privacy trade-offs in the ride-hailing services
Contains data from Paliński (2022), based on a discrete choice experiment studying users' willingness to accept discounts in exchange for data usage in ridehailing apps. The experiment includes a treatment related to GDPR awareness. Code provided in this folder requires working knowledge of the `apollo` package in R.

### Chapter 5 – Chapter 5	Behind the screens. Privacy and advertising preferences in VoD settings
Includes data from Paliński et al. (2025), examining users’ willingness to accept discounts for allowing data use in a video-on-demand (VoD) context. The estimation of DCE models in this chapter requires MATLAB and is based on scripts adapted from Prof. Czajkowski’s MXL modeling framework.

## Citation

If you use any data or code from this repository, please cite the relevant publications:

- Sobolewski, M., & Paliński, M. (2017). How much consumers value on-line privacy? Welfare assessment of new data protection regulation (GDPR). University of Warsaw Faculty of Economics Sciences Working Paper.
- Paliński, M. (2022). Paying with your data. Privacy tradeoffs in ride-hailing services. Applied economics letters, 29(18), 1719-1725.
- Paliński, M., Jusypenko, B., & Hardy, W. (2025). Behind the screens. Privacy and advertising preferences in VoD—the role of privacy concerns, persuasion knowledge, and experience. Journal of Retailing and Consumer Services, 84, 104233.

## License

This repository uses the following licenses:

- **Code** is released under the [MIT License](https://opensource.org/license/MIT).
- **Data** is shared under the [Creative Commons Attribution 4.0 International (CC BY 4.0)](https://creativecommons.org/licenses/by/4.0/) license.
