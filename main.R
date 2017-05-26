source("Agent.R")
source("Memory.R")
source("train.R")

N_EPISODE <- 500
BATCH_SIZE <- 32

gym <- import("gym")
env <- gym$make("CartPole-v0")
env <- gym$wrappers$Monitor(env, "monitor", force = TRUE)

tf$reset_default_graph()
agent <-
    Agent$new(
        input_shape = 4,
        output_dim = 2,
        epsilon_last_episode = 100
    )

memory <- Memory$new(capacity = 50000)

rewards <- c()

with(tf$Session() %as% sess, {
    init <- tf$global_variables_initializer()
    sess$run(init)
    
    for (episode_i in 1:N_EPISODE) {
        done <- FALSE
        s <- env$reset()
        total_reward = 0
        
        while (!done) {
            a <- agent$get_action(state_ = s, step = episode_i)
            ret <- env$step(action = a)
            
            s2 <- ret[[1]]
            r <- ret[[2]]
            done <- ret[[3]]
            
            memory$push(s, a, r, done, s2)
            
            if (memory$length > BATCH_SIZE) {
                batch <- memory$sample(BATCH_SIZE)
                train(agent, batch)
            }
            s <- s2
            total_reward <- total_reward + r
        }
        
        cat(
            sprintf(
                "[Episode: %4d] Reward: %4d, Epsilon: %.3f\n",
                episode_i,
                total_reward,
                agent$epsilon
            )
        )
        
        rewards <- append(rewards, total_reward)
        
        if (length(rewards) > 100) {
            rewards <- rewards[2:length(rewards)]
            
            if (mean(rewards) > 195) {
                cat("Game Cleared")
                break
            }
        }
    }
})

env$close()