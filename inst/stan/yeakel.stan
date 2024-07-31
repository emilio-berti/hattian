data {
  int N; // observations
  array[N] int<lower=0,upper=1> link;
  vector[N] mr;
}

parameters {
  real a1;
  real a2;
  real a3;
}

model{
  // priors
  a1 ~ normal(0, 10);
  a2 ~ normal(0, 10);
  a3 ~ normal(0, 10);

  // likelihood
  link ~ bernoulli_logit(a1 + a2 * mr + a3 * pow(mr, 2));
}

generated quantities{ // calculate correlation matrix R from Cholesky 
  vector[N] log_lik; {
    // auxilliary variables
    vector[N] p;
    for (i in 1:N) {
      p[i] = a1 + a2 * mr[i] + a3 * pow(mr[i], 2);
      log_lik[i] = bernoulli_logit_lpmf(link[i] | p[i]);
    }
  }
}
