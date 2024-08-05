data {
  int N; // observations
  array[N] int<lower=0,upper=1> link;
  vector[N] mi;
  vector[N] mr;
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
  real mu;
  real sigma;
  real theta;
  vector[N] p;

  for (i in 1:N) {
    mu = alpha0 + alpha1 * mi[i];
    sigma = exp(beta0 + beta1 * mi[i]);
    theta = exp( (gamma0 + gamma1 * mi[i])/(1 + exp(gamma0 + gamma1 * mi[i])) );
    p[i] = theta * exp( - (mr[i] - mu)^2 / (2 * sigma^2) );
  }
  
  // likelihood
  link ~ bernoulli(p);
}

generated quantities{ // calculate correlation matrix R from Cholesky 
  vector[N] log_lik; {
    
    // auxilliary variables
    real mu;
    real sigma;
    real theta;
    vector[N] p;

    // likelihood
    for (i in 1:N) {
      mu = alpha0 + alpha1 * mi[i];
      sigma = exp(beta0 + beta1 * mi[i]);
      theta = exp( (gamma0 + gamma1 * mi[i])/(1 + exp(gamma0 + gamma1 * mi[i])) );
      p[i] = theta * exp( - (mr[i] - mu)^2 / (2 * sigma^2) );
      log_lik[i] = bernoulli_lpmf(link[i] | p[i]);
    }
  }
}
