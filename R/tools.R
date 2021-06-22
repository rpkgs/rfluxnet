#' @export 
str_split <- function(x, split = "-", names = NULL) {
    ans = strsplit(x, split) %>% map(as.numeric) %>% do.call(rbind, .) %>% as.data.table() 
    if (!is.null(names)) ans %<>% set_names(names)
    ans
}
