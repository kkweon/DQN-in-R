train <- function(agent, memory, discount = .99) {
    # states, actions, rewards, dones, states2
    n_samples <- nrow(memory$states)
    
    X_batch <- memory$states
    y_batch <- agent$predict(X_batch)
    y_future <- agent$predict(memory$states2)
    
    for (i in 1:n_samples) {
        action_idx <- memory$actions[i] + 1L
        if (memory$dones[i] == T) {
            y_batch[i, action_idx] <- memory$rewards[i]
        } else {
            y_batch[i, action_idx] <-
                memory$rewards[i] + discount * max(y_future[i, ])
        }
    }
    agent$train(X_batch, y_batch)
}