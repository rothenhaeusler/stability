#' Evaluation of model stability under distribution shift
#' @param model An object as returned by lm or glm 
#' @param param A coefficient in summary(model)
#' @param E A subset of predictors in the formula of the model
#' @examples
#' fit <- lm(sr ~ pop15 + pop75 + dpi + ddpi,
#' data = LifeCycleSavings)
#' stability(fit,param="pop15",E="dpi")
#' stability(fit,param="pop15")
#'
#' utils::data(anorexia, package = "MASS")
#' fit <- glm(Postwt ~ Prewt + Treat,family = gaussian, data = anorexia)
#' stability(fit,param = "TreatCont")
#'
#' @export
stability <- function(model,param,E=NULL) {
  infl <- influence(model)
  n <- length(model$fitted.values)
  influence_values <- n*infl$coefficients[,param]
  target_coef <- coef(model)[param]
  
  
  x <- seq(0,2,length.out=100)
  main = paste("Stability of parameter",param)
  plot(x,type = "n",col = "red", xlab = "Distribution shift in KL divergence", ylab = "Range of parameter under distribution shift", main = main,xlim=c(0,2),ylim = c(min(0,2*target_coef),max(0,2*target_coef)))
  
  if (is.null(E)) { E <- names(model$model)}
  
  for (j in 1:length(E)){
    
    if (is.numeric(model$model[,E[j]])){
      splines <- loess(influence_values~model$model[,E[j]])
      f_values <- splines$fitted
    } else {
      f_values <- fitted.values(lm(influence_values ~ model$model[,E[j]]))
    }
    
    
    y <- t(rbind(target_coef - 2*sqrt(x)*sd(f_values),target_coef + 2*sqrt(x)*sd(f_values)))
    lines(cbind(x,y[,1]), type = "l", col = j)
    lines(cbind(x,y[,2]), type = "l", col = j)
    
  }
  legend(2,max(0,2*target_coef),xjust=1,pch=19,legend=E,col=1:length(E), title="Shift of ...")
  
}
