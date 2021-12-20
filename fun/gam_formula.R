## create a formular object

gam_formula <- function(matrix, index.y, index.x, arg='', pred=T) {
  
  mat <- deparse(substitute(matrix))
  if (pred==F){
    if (length(index.x)==1) {
      form <- paste(mat, '[,', index.y, '] ~ s(', mat, '[,', index.x, ']', arg, ')', sep='')
    } else {
      
      form <- paste(mat, '[,', index.y, '] ~  ', sep='')
      for(i in index.x[-length(index.x)]){
        form <- paste(form, 's(', mat, '[,', i, ']', arg, ') + ', sep='')
      }
      form <- paste(form, 's(', mat, '[,', index.x[length(index.x)], ']', arg, ')', sep='')
    }
  }
  
  if (pred==T){
    coln <- colnames(matrix)
    if (length(index.x)==1) {
      form <- paste(coln[index.y],'~ s(', coln[index.x], arg, ')', sep='')
    } else {
      
      form <- paste(coln[index.y], ' ~ ', sep='')
      for(i in index.x[-length(index.x)]){
        form <- paste(form, 's(', coln[i], arg, ') + ', sep='')
      }
      form <- paste(form, 's(', coln[index.x[length(index.x)]], arg, ')', sep='')
    }
  }
  return(as.formula(form))
}
