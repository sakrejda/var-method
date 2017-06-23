
## @knitr reporting-approximation
f <- function(t, shape, scale, a, b) { 
	pweibull(q=t-b, shape=shape, scale=scale) - pweibull(q=t-a, shape=shape, scale=scale) 
}

x <- seq(from=0, to=12, length.out=200)
y <- -f(t=x, shape=2, scale=3, a=1.2, b=4)/2
oi <- data.frame(
	x=x, y=y, ts='integrated'
)

o <- list()
ts <- seq(from=1.2, to=4, length.out=6)
for ( i in 1:length(ts)) {
	o[[i]] <- data.frame(
		x = x, 
		y = dweibull(x=x-ts[i], shape=2, scale=3),
		ts = as.character(ts[i])
	)
}

o <- do.call(what=rbind, args=c(list(oi), o))
o[['group']] <- 'conditional'
o[['group']][o[['ts']] == 'integrated'] <- 'integrated'

pl <- ggplot(
	data=o, aes(x=x, y=y, colour=group, linetype=group, group=ts)					 
) + geom_line() +
		xlab(expression(t[r])) +
		ylab(expression(paste("p(",t[r],"|k,",lambda,",a,b)"))) + 
		geom_vline(xintercept=c(1.2,4))

saveRDS(object=pl, file=file.path(figure_dir,'reporting-approximation.rds'))

## @knitr reporting-integration-result
G <- incomplete_upper_gamma <- function(a,x)	pgamma(x, a, lower=FALSE) 
g <- incomplete_upper_gamma <- function(a,x)	pgamma(x, a, lower=TRUE )




g <- function(lb, ub, t_now, a, b, k, l) {
	K <- 1/(ub-lb)
	A <- (a-t_now) / ((t_now - a) * l) * 
	B <- 
	C <- 
	D <- 
	o <- K * ( (A+B) - (C+D) )
	return(o)
}





