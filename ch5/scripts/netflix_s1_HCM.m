% The script requires:
% https://github.com/czaj/dce
% https://github.com/czaj/tools
% (they need to be downloaded and included in Matlab paths (with subfolders))

clear all
clc
global B_backup; % this is for storing B (parameters) vector in case iterations are interrupted with ctrl-c

%% ****************************  loading data  ****************************
EstimOpt.DataFile = ('netflix_s1.mat'); % specify the name of the data file

DATA = load(EstimOpt.DataFile); % load data, store it in a structure DATA

%% ****************************  data description  ****************************
%tableDCE = [DATA.RID, DATA.index, DATA.SCENARIO, DATA.block, DATA.alt, DATA.choice, DATA.x1, DATA.x2, DATA.x3, DATA.x4, DATA.x5, DATA.x6, DATA.x7, DATA.x8,];
%tableDCE = array2table(tableDCE, 'VariableNames', {'RID','Id', 'Scenario', 'Block' 'Alt', 'Choice', 'Ratings','History','AgeGender','Location','ExternalData','Ads','AdsTime','Discount'});

%% ****************************  model specification  ****************************

EstimOpt.ProjectName = 'Netflix'; % name of the project used for naming xls results files

DATA.Y = DATA.choice; % explained variable (choice indicator)

DATA.Xa = [DATA.alt==1, DATA.alt==2, DATA.x1, DATA.x2, DATA.x3, DATA.x4, DATA.x5, (DATA.x6==2), DATA.x7, DATA.x8/10]; % discount/10 -> to ease model convergence;
EstimOpt.NamesA = {'ASC1'; 'ASC2'; 'Ratings'; 'History'; 'AgeGender';'Location';'ExternalData'; 'AdsP'; 'AdsTime'; 'Discount/10'};

DATA.treatment = logical(DATA.treatment2_attentive);

DATA.Xm = [DATA.treatment2_attentive];
EstimOpt.NamesM = {'DisplayTreatment'};
%% ****************************  specifying input ****************************

% DATA.filter = ones(size(DATA.Y)) == 1; % modify to include only some observations, e.g. model for male respondents only
INPUT.Y = DATA.Y; 
INPUT.Xa = DATA.Xa;
INPUT.Xm = DATA.Xm;
% INPUT.Xm = DATA.Xm(DATA.filter,:); % Explanatory variables of random parameters means / inreactions
% INPUT.Xs = DATA.Xs(DATA.filter,:); % Explanatory variables of scale
% INPUT.Xt = DATA.Xt(DATA.filter,:); % Explanatory variables of scale variance (GMXL model)
% INPUT.Xc = DATA.Xc(DATA.filter,:); % Explanatory variables of class membership (Latent class models)
% INPUT.Xmea = DATA.Xmea(DATA.filter,:); % Measurment equations variables (Hybrid models)
% INPUT.Xmea_exp = DATA.Xmea_exp(DATA.filter,:); % Additional covariates explaining mesurment equations (Hybrid models)
% INPUT.Xstr = [DATA.female,DATA.city,DATA.high_edu];
% INPUT.Xstr = DATA.Xstr(DATA.filter,:); % Structural equations variables (Hybrid models)
INPUT.Xstr = [DATA.female,DATA.city,DATA.high_edu,DATA.treatment];
EstimOpt.NamesStr = {'female','city','high_edu','display_treatment'};
% INPUT.MissingInd = DATA.SKIP(DATA.filter,:); % use to indicate missing observations, e.g. choice tasks with no answer


%% ****************************  sample characteristics ****************************


EstimOpt.NCT = 8; % Number of choice tasks per person 
EstimOpt.NAlt = 3; % Number of alternatives
EstimOpt.NP = length(INPUT.Y)/EstimOpt.NCT/EstimOpt.NAlt; % Number of respondents


%% **************************** estimation and optimization options ****************************


EstimOpt.eps = 1.e-9; % overall precision level

[INPUT, Results, EstimOpt, OptimOpt] = DataCleanDCE(INPUT,EstimOpt);

EstimOpt.NRep = 1e3; % number of draws for numerical simulation
% OptimOpt.MaxIter = 1e3; % maximum number of iterations
% OptimOpt.Algorithm = 'trust-region'; % 'quasi-newton'
% EstimOpt.NumGrad = 1; % 0
% OptimOpt.GradObj = 'off'; % 'off'
% OptimOpt.FinDiffType = 'central'; % 'forward'
% OptimOpt.Hessian = 'user-supplied'; % 'off'
% EstimOpt.HessEstFix = 1s; % 0 = use optimization Hessian, 1 = use jacobian-based (BHHH) Hessian, 2 - use high-precision jacobian-based (BHHH) Hessian 3 - use numerical Hessian
% EstimOpt.ApproxHess = 0;

% Estimopt.RealMin = 1; % use in the case of numerical errors (possibly for a few iterations only)


%% ****************************     MNL     ****************************

EstimOpt.WTP_space = 1; % number of monetary attributes for WTP-space estimation (need to come last in Xa)
% EstimOpt.WTP_matrix = []; % specify which monetary parameter is used for which non-monetary attribute for WTP-space models
% EstimOpt.NLTType = 1 % 1 = Box-Cox transformations; 2 = Yeo-Johnson transofmarions (MNL and MXL only)
% EstimOpt.NLTVariables = []; % choose Xa to be non-linearly transformed (MNL and MXL only)

% Optional: pass starting values either using B_backup (global variable automatically saved at each iteration) or Results.MNL.b0
% B_backup = [0.074;0.11;-0.1;-0.033;-0.066;-0.14;0.27;-0.029;0.1;-0.012;0.044;0.12;-0.003;0.049;-0.025;0.049;-0.00054;-0.053];
OptimOpt.Algorithm = 'trust-region'; % 'quasi-newton';
OptimOpt.Hessian = 'user-supplied'; % 'off'

% OptimOpt.Algorithm = 'quasi-newton';
% OptimOpt.Hessian = 'off';

Results.MNL = MNL(INPUT,Results,EstimOpt,OptimOpt);

%% ****************************     MXL_d     ****************************

% EstimOpt.WTP_space = 1; % number of monetary attributes for WTP-space estimation (need to come last in Xa)
% EstimOpt.FullCov = 0;
EstimOpt.Dist = [0;0;0;0;0;0;0;0;0;1]; % optional: AdsTime lognormal

% B_backup = [0,0,0,0,0,0,0,0,-1];

Results.MXL = MXL(INPUT,Results,EstimOpt,OptimOpt);

%% ****************************     HMXL_d     ****************************
EstimOpt.NLatent = 2;
INPUT.Xmea = [DATA.q16_1,DATA.q16_2,DATA.q16_3,DATA.q16_4,DATA.q262_1,DATA.q262_2,DATA.q262_3,DATA.q262_4];
EstimOpt.NamesMea = {'ads1','ads2','ads3','ads4','net1','net2','net3','net4'};

EstimOpt.MeaMatrix = [1 1 1 1 0 0 0 0  ; ...
                      0 0 0 0 1 1 1 1  ; ...
                      ];

EstimOpt.MeaSpecMatrix = [2];

EstimOpt.FullCov = 0;

% B_backup = [-1.1863936151292135968;0.8100159302560846486;-1.4761390114132448836;0.74339536228005975715;2.4048971350289942706;1.5808751669470322287;0.48723630726156613724;1.2923693853728603909;0;0;0.94457242872305691161;0;0;0;-0.60910613192101137336;0;0;0;-0.04938522467448652753;0;0;0;-0.34514206638887207079;0;0;0;0.06137634855341076584;0;0;0;-0.77679094314073415806;0;0;0;-0.46730941911909723574;0;0;0;0.59701345726712296003;0;-0.18516360231222792065;-1.1719835422058162422;-0.37019459087453671087;-0.57193879456064045108;0.10736601055416811201;-1.2127340313551224771;-0.79695205082660847129;0.13958425315693717694;-0.4489985994625657062;0.40734657267637469635;-0.41520736227722615519;-2.3602505157295796678;0.09820592992580901015;-0.14636090020784695009;0.21161950850843774807;-0.15307156629551596505;-1.1439531568136254158;-0.10932776505693950209;-0.274710725674727263;-0.11050680043783617235;-0.014118535791687595454;-2.070026098153683769;0.017919944140045624553;-0.35128344796499366698;0.13469622335087202969;0.0076364454490646460974;-1.9950625318931582974;-0.21080195833136447514;-0.28011130394120098419;0.11830580404877050205;0.80519613725390182246;-2.7166025070747448211;-0.011441775399824948706;0.18826295356999717123;0.52464879645123962959;-0.14749169623220997893;-1.7131662206723403674;-0.36049138191155150057;-0.4972630915582898492;0.010576005871886779222];
% EstimOpt.BActive = ones(size(B_backup));
% EstimOpt.BActive([9,10,12, 13,14,16, 17,18,20, 21,22,24, 25,26,28, 29,30,32, 33,34,36, 37,38,40]) = 0;
% B_backup = B_backup .* EstimOpt.BActive;

EstimOpt.RealMin = 1;

OptimOpt.Algorithm = 'trust-region'; % 'quasi-newton';
OptimOpt.Hessian = 'user-supplied'; % 'off'

EstimOpt.NRep = 1e3; % number of draws for numerical simulation
% Results.HMNL = HMNL(INPUT,Results,EstimOpt,OptimOpt);

EstimOpt.NRep = 5e3; % number of draws for numerical simulation
% Results.HMXL = HMXL(INPUT,Results,EstimOpt,OptimOpt);