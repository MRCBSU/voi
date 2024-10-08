% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/evppivar.R
\name{evppivar}
\alias{evppivar}
\title{Calculate the expected value of partial perfect information for an estimation problem}
\usage{
evppivar(
  outputs,
  inputs,
  pars = NULL,
  method = NULL,
  nsim = NULL,
  verbose = TRUE,
  ...
)
}
\arguments{
\item{outputs}{a vector of values for the quantity of interest, sampled from the uncertainty distribution of this quantity that is induced by the uncertainty about the parameters.   This can also be a data frame with one column.

Typically this will come from a Monte Carlo sample, where we first sample from the uncertainty distributions of the parameters, and then compute the quantity of interest as a function of the parameters.  It might also be produced by a Markov Chain Monte Carlo sample from the joint distribution of parameters and outputs.}

\item{inputs}{Matrix or data frame of samples from the uncertainty
distribution of the input parameters of the decision model.   The number
of columns should equal the number of parameters, and the columns should
be named.    This should have the same number of rows as there are samples
in \code{outputs}, and each row of the samples in \code{outputs} should
give the model output evaluated at the corresponding parameters.

Users of \pkg{heemod} can create an object of this form, given an object
produced by \code{run_psa} (\code{obj}, say), with \code{\link{import_heemod_inputs}}.}

\item{pars}{Either a character vector, or a list of character vectors.

If a character vector is supplied, then a single, joint EVPPI calculation is done with
for the parameters named in this vector.

If a list of character vectors is supplied,  then multiple EVPPI calculations are
performed, one for each list component defined in the above
vector form.

\code{pars} must be specified if \code{inputs} is a matrix or data frame.
This should then correspond to particular columns of \code{inputs}.    If
\code{inputs} is a vector, this is assumed to define the single parameter
of interest, and then \code{pars} is not required.}

\item{method}{Character string indicating the calculation method.  If one
string is supplied, this is used for all calculations.  A vector of different strings
can be supplied if a different method is desired for different list components
of \code{pars}.

The default methods are based on nonparametric regression:

\code{"gam"} for a generalized additive model implemented in the \code{\link[mgcv]{gam}}
function from the \pkg{mgcv} package.  This is the default method for
calculating the EVPPI of 4 or fewer parameters.

\code{"gp"} for a Gaussian process regression, as described by Strong et al.
(2014) and implemented in the \pkg{SAVI} package
(\url{https://github.com/Sheffield-Accelerated-VoI/SAVI}).  This is the default method for calculating the EVPPI
of more than 4 parameters.

\code{"inla"} for an INLA/SPDE Gaussian process regression method, from
Heath et al. (2016).

\code{"bart"} for Bayesian additive regression trees, using the \pkg{dbarts} package.
Particularly suited for joint EVPPI of many parameters.

\code{"earth"} for a multivariate adaptive regression spline with the
\pkg{earth} package (Milborrow, 2019).

\code{"so"} for the method of Strong and Oakley (2013).  Only supported
for single parameter EVPPI.

\code{"sal"} for the method of Sadatsafavi et al. (2013).  Only supported
for single parameter EVPPI.}

\item{nsim}{Number of simulations from the decision model to use
for calculating EVPPI.  The first \code{nsim} rows of the
objects in \code{inputs} and \code{outputs} are used.}

\item{verbose}{If \code{TRUE}, then messages are printed
describing each step of the calculation, if the method supplies
these.  Can be useful to see the progress of slow calculations.}

\item{...}{Other arguments to control specific methods.

For \code{method="gam"}, the following arguments can be supplied:
\itemize{
\item \code{gam_formula}: a character string giving the right hand side of the
formula supplied to the \code{gam()} function. By default, this is a tensor
product of all the parameters of interest, e.g. if \code{pars =
c("pi","rho")}, then \code{gam_formula} defaults to \code{t(pi, rho,
bs="cr")}.  The option \code{bs="cr"} indicates a cubic spline regression
basis, which is more computationally efficient than the default "thin plate"
basis.  If there are four or more parameters of interest, then the
additional argument \code{k=4} is supplied to \code{te()}, specifying a
four-dimensional basis, which is currently the default in the SAVI package.

If there are spaces in the variable names in \code{inputs}, then these should
be converted to underscores before forming an explicit \code{gam_formula}.
}

For \code{method="gp"}, the following arguments can be supplied:
\itemize{
\item \code{gp_hyper_n}: number of samples to use to estimate the hyperparameters
in the Gaussian process regression method.  By default, this is the minimum
of the following three quantities: 30 times the number of parameters of
interest, 250, and the number of simulations being used for calculating
EVPPI.
\item \code{maxSample}: Maximum sample size to employ for \code{method="gp"}.  Only
increase this from the default 5000 if your computer has sufficent memory to
invert square matrices with this dimension.
}

For \code{method="inla"}, the following arguments can be supplied, as described in detail in Baio, Berardi and Heath (2017):
\itemize{
\item \code{int.ord} (integer) maximum order of interaction terms to include in
the regression predictor, e.g. if \code{int.ord=k} then all k-way
interactions are used.  Currently this applies to both effects and costs.
\item \code{cutoff} (default 0.3) controls the
density of the points inside the mesh in the spatial part of the mode.
Acceptable values are typically in
the interval (0.1,0.5), with lower values implying more points (and thus
better approximation and greatercomputational time).
\item \code{convex.inner} (default = -0.4) and \code{convex.outer} (default = -0.7)
control the boundaries for the mesh. These should be negative values and can
be decreased (say to -0.7 and -1, respectively) to increase the distance
between the points and the outer boundary, which also increases precision and
computational time.
\item \code{robust}. if \code{TRUE} then INLA will use a t prior distribution for
the coefficients of the linear predictor, rather than the default normal distribution.
\item \code{h.value} (default=0.00005) controls the accuracy of the INLA
grid-search for the estimation of the hyperparameters. Lower values imply a
more refined search (and hence better accuracy), at the expense of
computational speed.
\item \code{plot_inla_mesh} (default \code{FALSE}) Produce a plot of the mesh.
\item \code{max.edge}  Largest allowed triangle edge length when constructing the
mesh, passed to \code{\link[INLA]{inla.mesh.2d}}.
\item \code{pfc_struc} Variance structure to pass to \code{pfc} in the \pkg{ldr}
package for principal fitted components. The default \code{"AIC"} selects the
one that fits best given two basis terms.  Change this to, e.g. \code{"iso"},
\code{"aniso"} or \code{"unstr"} if an "Error in eigen..." is obtained.
}

For any of the nonparametric regression methods:
\itemize{
\item \code{ref} The reference decision option used to define the
incremental net benefit, cost or effects before performing
nonparametric regression.  Either an integer column number, or the
name of the column from \code{outputs}.
}

For \code{method="so"}:
\itemize{
\item \code{n.blocks} Number of blocks to split the sample into. Required.
}

For \code{method="sal"}:
\itemize{
\item \code{n.seps} Number of separators (default 1).
}}
}
\value{
A data frame with a column \code{pars}, indicating the parameter(s), and a column \code{evppi}, giving the corresponding EVPPI.
}
\description{
Calculate the expected value of partial perfect information for an estimation problem.  This computes the expected reduction in variance in some quantity of interest with perfect information about a parameter or parameters of interest.
}
\references{
Jackson, C., Presanis, A., Conti, S., & De Angelis, D. (2019). Value of information:
Sensitivity analysis and research design in Bayesian evidence synthesis.
Journal of the American Statistical Association, 114(528), 1436-1449.

Jackson, C., Johnson, R., de Nazelle, A., Goel, R., de Sa, T. H.,
Tainio, M., & Woodcock, J. (2021). A guide to value of information
methods for prioritising research in health impact
modelling. Epidemiologic Methods, 10(1).

Jackson, C. H., Baio, G., Heath, A., Strong, M., Welton, N. J., &
Wilson, E. C. (2022). Value of Information analysis in models to
inform health policy. Annual Review of Statistics and its
Application, 9, 95-118.
}
