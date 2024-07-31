data {
  int N; // observations
  int S; // species
  int B; // basal species
  array[N] int<lower=0,upper=1> link;
  vector[N] mi;
  vector[N] mr;

  // I had some issues with to_int(ceil(i / S)) and found another, 
  // less elegant solution.
  array[N] int s; //species ID
}

parameters {
  real alpha0;
  real alpha1;
  real beta0;
  real beta1;
  real gamma0;
  real gamma1;
}

model{
  // priors
  alpha0 ~ normal(0, 10);
  alpha1 ~ normal(0, 10);
  beta0 ~ normal(0, 10);
  beta1 ~ normal(0, 10);
  gamma0 ~ normal(0, 10);
  gamma1 ~ normal(0, 10);

  // auxilliary variables
  vector[S - B] mu;
  vector[S - B] sigma;
  vector[S - B] theta;
  vector[N] p;

  for (i in 1:N) {
    //s = to_int(ceil(i / S));
    mu[s[i]] = alpha0 + alpha1 * mi[i];
    sigma[s[i]] = exp(beta0 + beta1 * mi[i]);
    theta[s[i]] = exp( (gamma0 + gamma1 * mi[i])/(1 + exp(gamma0 + gamma1 * mi[i])) );
    p[i] = theta[s[i]] * exp( - (mr[i] - mu[s[i]])^2 / (2 * sigma[s[i]]^2) );
  }
  
  // likelihood
  link ~ bernoulli(p);
}

generated quantities{ // calculate correlation matrix R from Cholesky 
  vector[S - B] mu; 
  vector[S - B] sigma;
  vector[S - B] theta;
  vector[N] log_lik; {
    
    // auxilliary variables
    vector[N] p;

    // likelihood
    for (i in 1:N) {
      //s = to_int(ceil(i / S));
      mu[s[i]] = alpha0 + alpha1 * mi[i];
      sigma[s[i]] = exp(beta0 + beta1 * mi[i]);
      theta[s[i]] = exp( (gamma0 + gamma1 * mi[i])/(1 + exp(gamma0 + gamma1 * mi[i])) );
      p[i] = theta[s[i]] * exp( - (mr[i] - mu[s[i]])^2 / (2 * sigma[s[i]]^2) );
      log_lik[i] = bernoulli_lpmf(link[i] | p[i]);
    }
  }
}
