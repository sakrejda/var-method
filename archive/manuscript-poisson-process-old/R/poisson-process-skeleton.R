

time <- 1:10
rate <- seq(from=11, to=20, length.out=length(time))
n_per_batch <- 5
data <- data.frame(
	time = rep(time,n_per_batch),
	rate = rep(rate,n_per_batch)
)
data[['count']] <- rpois(n=nrow(data), lambda=data[['rate']])
data <- data[order(data[['time']]),]

f <- function(lambdas) {
	data[['lambda']] <- lambdas[data[['time']]]
	ll <- sum(dpois(x=data[['count']], lambda=data[['lambda']], log=TRUE))
	return(-ll)
}

optzd <- optim(
	par = 12:21, 
	fn = f, gr=NULL,
	method = c("L-BFGS-B"),
	lower=10^-10, upper=50
)

g <- function(t) optzd[['par']][floor(t)+1]

ptzd <- data.frame(
	x = 0:9+.5,
	y = g(0:9+0.5)
)

library(ggplot2)
pl <- ggplot(
	data=data, 
	aes(x=time-0.5, y=count)
) + geom_point() +
		geom_bar( data=ptzd, aes(x=x,y=y), alpha=0.4, stat='identity')



saveRDS(object=pl, file=file.path(figure_dir,'discrete-homo-poisson-process.rds'))



pl <- readRDS(file=file.path(figure_dir, 'discrete-homo-poisson-process.rds'))
print(pl)



library(cruftery)
data <- data.frame(
	x=seq(from=0, to=10, length.out=10^3),
	y=gaussian_spline(x=seq(from=0, to=10, length.out=10^3),
	knot_points=2:8, knot_weights=exp(rnorm(7))*2+c(0,2,2,2,rep(0,3)), knot_scale=0.5)
)
shade <- data[data[['x']] >= 3 & data[['x']] < 5,]
shade <- rbind(
	data.frame(x=3,y=0),
	shade,
	data.frame(x=5,y=0)
)


pl <- ggplot(data=data, aes(x=x, y=y)) + geom_line() + 
			geom_polygon(data=shade, aes(x=x, y=y), alpha=0.3) +
			xlab('Time (days)') + ylab('Intensity (Cases per day)') +
			annotate("text", x=3, y=-.2, label="s") +
			annotate("text", x=5, y=-.2, label="t") +
			annotate("text", x=4, y= .8, label=
				"m(s,t)==integral(lambda(x)*dx,s,t)", parse=TRUE)



saveRDS(object=pl, file=file.path(figure_dir,'cont-inhomo-poisson-process.rds'))



pl <- readRDS(file=file.path(figure_dir, 'cont-inhomo-poisson-process.rds'))
print(pl)


