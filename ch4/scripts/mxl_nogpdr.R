# ################################################################# #
#### LOAD LIBRARY AND DEFINE CORE SETTINGS                       ####
# ################################################################# #

### Clear memory
rm(list = ls())

### Load Apollo library
library(apollo)

### Initialise code
apollo_initialise()

### Set core controls
apollo_control = list(
  modelName ="NCN_mxl_nogdpr",
  modelDescr ="Mixed logit model on privacy choices - nogdpr",
  indivID   ="TOKEN",  
  mixing    = TRUE, 
  nCores    = 4
)

# ################################################################# #
#### LOAD DATA AND APPLY ANY TRANSFORMATIONS                     ####
# ################################################################# #

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
database = read.csv("../data/in.csv",header=TRUE)
database = subset(database, `GROUP.1` == 'BEZ RODO')
# ################################################################# #
#### DEFINE MODEL PARAMETERS                                     ####
# ################################################################# #

### Vector of parameters, including any that are kept fixed in estimation
apollo_beta = c(
  # asc_mu = 0,
  # asc_sigma =1,
  
  pd.name_mu = -.36,
  pd.name_sigma = .1,
  pd.birth_mu = -.13,
  pd.birth_sigma = .1,
  pd.sm_mu = -.49,
  pd.sm_sigma = .1,
  pd.search_mu = 0,
  pd.search_sigma = .1,
  
  ld.route_mu = -.17,
  ld.route_sigma = .1,
  ld.hist_mu = 0,
  ld.hist_sigma = .1,
  
  cd.email_mu = -.38,
  cd.email_sigma = .1,
  cd.tel_mu = -.23,
  cd.tel_sigma = .1,
  
  ua.app_mu = .31,
  ua.app_sigma = .1,
  ua.ad_mu = .23,
  ua.ad_sigma = .1,
  ua.surv_mu = .35,
  ua.surv_sigma = .1,
  
  discount_mu = -.31,
  discount_sigma =.1
)

### Vector with names (in quotes) of parameters to be kept fixed at their starting value in apollo_beta, use apollo_beta_fixed = c() if none
apollo_fixed = c()

# ################################################################# #
#### DEFINE RANDOM COMPONENTS                                    ####
# ################################################################# #

### Set parameters for generating draws
apollo_draws = list(
  interDrawsType = "sobolOwen",
  interNDraws    = 1000,
  interUnifDraws = c(),
  interNormDraws = c("draws_pd.name", "draws_pd.birth", "draws_pd.sm", "draws_pd.search", "draws_ld.route", "draws_ld.hist", "draws_cd.email", "draws_cd.tel", "draws_ua.app", "draws_ua.ad", "draws_ua.surv", "draws_discount"), 
  # "draws_asc"),
  intraDrawsType = "halton",
  intraNDraws    = 0,
  intraUnifDraws = c(),
  intraNormDraws = c()
)

### Create random parameters
apollo_randCoeff = function(apollo_beta, apollo_inputs){
  randcoeff = list()
  
  # randcoeff[["asc"]] = asc_mu + asc_sigma*draws_asc
  
  randcoeff[["pd.name"]] = pd.name_mu + pd.name_sigma * draws_pd.name
  randcoeff[["pd.birth"]] = pd.birth_mu + pd.birth_sigma * draws_pd.birth
  randcoeff[["pd.sm"]] = pd.sm_mu + pd.sm_sigma * draws_pd.sm
  randcoeff[["pd.search"]] = pd.search_mu + pd.search_sigma * draws_pd.search
  
  randcoeff[["ld.route"]] = ld.route_mu + ld.route_sigma * draws_ld.route
  randcoeff[["ld.hist"]] = ld.hist_mu + ld.hist_sigma * draws_ld.hist
  
  randcoeff[["cd.email"]] = cd.email_mu + cd.email_sigma * draws_cd.email
  randcoeff[["cd.tel"]] = cd.tel_mu + cd.tel_sigma * draws_cd.tel
  
  randcoeff[["ua.app"]] = ua.app_mu + ua.app_sigma * draws_ua.app
  randcoeff[["ua.ad"]] = ua.ad_mu + ua.ad_sigma * draws_ua.ad
  randcoeff[["ua.surv"]] = ua.surv_mu + ua.surv_sigma * draws_ua.surv
  
  randcoeff[["discount"]] = exp(discount_mu + discount_sigma*draws_discount)
  
  return(randcoeff)
}

# ################################################################# #
#### GROUP AND VALIDATE INPUTS                                   ####
# ################################################################# #

apollo_inputs = apollo_validateInputs()

# ################################################################# #
#### DEFINE MODEL AND LIKELIHOOD FUNCTION                        ####
# ################################################################# #

apollo_probabilities=function(apollo_beta, apollo_inputs, functionality="estimate"){
  
  ### Function initialisation: do not change the following three commands
  ### Attach inputs and detach after function exit
  apollo_attach(apollo_beta, apollo_inputs)
  on.exit(apollo_detach(apollo_beta, apollo_inputs))
  
  ### Create list of probabilities P
  P = list()
  
  ### List of utilities: these must use the same names as in mnl_settings, order is irrelevant
  V = list()
  
  V[['alt1']]  =  alt1.a_1*pd.name + alt1.a_2*pd.birth + alt1.a_3*pd.sm + alt1.a_4*pd.search + alt1.b_1*ld.route + alt1.b_2*ld.hist + alt1.c_1*cd.email + alt1.c_2*cd.tel + alt1.d_1*ua.app + alt1.d_2*ua.ad + alt1.d_3*ua.surv + alt1.discount*discount
  V[['alt2']]  =  alt2.a_1*pd.name + alt2.a_2*pd.birth + alt2.a_3*pd.sm + alt2.a_4*pd.search + alt2.b_1*ld.route + alt2.b_2*ld.hist + alt2.c_1*cd.email + alt2.c_2*cd.tel + alt2.d_1*ua.app + alt2.d_2*ua.ad + alt2.d_3*ua.surv + alt2.discount*discount
  V[['alt3']]  =  alt3.a_1*pd.name + alt3.a_2*pd.birth + alt3.a_3*pd.sm + alt3.a_4*pd.search + alt3.b_1*ld.route + alt3.b_2*ld.hist + alt3.c_1*cd.email + alt3.c_2*cd.tel + alt3.d_1*ua.app + alt3.d_2*ua.ad + alt3.d_3*ua.surv + alt3.discount*discount
  V[['alt4']]  =  alt4.a_1*pd.name + alt4.a_2*pd.birth + alt4.a_3*pd.sm + alt4.a_4*pd.search + alt4.b_1*ld.route + alt4.b_2*ld.hist + alt4.c_1*cd.email + alt4.c_2*cd.tel + alt4.d_1*ua.app + alt4.d_2*ua.ad + alt4.d_3*ua.surv + alt4.discount*discount
  # V[['alt4']]  =  asc*asc.4
  
  
  ### Define settings for MNL model component
  mnl_settings = list(
    alternatives  = c(alt1=1, alt2=2, alt3=3, alt4=4),
    avail         = list(alt1=1, alt2=1, alt3=1, alt4=1),
    choiceVar     = choice,
    V             = V
  )
  
  ### Compute probabilities using MNL model
  P[['model']] = apollo_mnl(mnl_settings, functionality)
  
  ### Take product across observation for same individual
  P = apollo_panelProd(P, apollo_inputs, functionality)
  
  ### Average across inter-individual draws
  P = apollo_avgInterDraws(P, apollo_inputs, functionality)
  
  ### Prepare and return outputs of function
  P = apollo_prepareProb(P, apollo_inputs, functionality)
  return(P)
}

# ################################################################# #
#### MODEL ESTIMATION                                            ####
# ################################################################# #

model = apollo_estimate(apollo_beta, apollo_fixed,
                        apollo_probabilities, apollo_inputs, 
                        estimate_settings=list())

# ################################################################# #
#### MODEL OUTPUTS                                               ####
# ################################################################# #

# ----------------------------------------------------------------- #
#---- FORMATTED OUTPUT (TO SCREEN)                               ----
# ----------------------------------------------------------------- #

apollo_modelOutput(model)

# ----------------------------------------------------------------- #
#---- FORMATTED OUTPUT (TO FILE, using model name)               ----
# ----------------------------------------------------------------- #

apollo_saveOutput(model)

