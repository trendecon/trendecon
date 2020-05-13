aggregate_samples <- function(x,
                              stepsize = 7) {
  groups <- x %>% 
    group_by(window) %>% 
    # If 100 is in the last stepsize values a rescaling has happened here
    mutate(starts_scaling_window = any(value[max(n()-stepsize+1, 1):n()] == 100)) %>%
    # If 100 is in the first stepsize values a rescaling is imminent because the max is moving out of the window
    mutate(next_starts_scaling_window = any(value[1:stepsize] == 100)) %>% 
    # Summarize
    summarize(ssw = any(starts_scaling_window), nssw = any(next_starts_scaling_window)) %>% 
    # lag next_starts_scaling_window forward 1 and combine
    mutate(starts_group = ssw | lag(nssw, 1, FALSE)) %>% 
    # Create group ids
    transmute(window = window, scaling_group = cumsum(starts_group))
  
  # Take the mean from all windows with the same scale
  y <- x %>% 
    left_join(groups, by = c(window = "window")) %>% 
    group_by(scaling_group, time) %>% 
    summarize(value = mean(value))
  
  # We now have the mean of all comparable windows
  # Next: chain them together
}