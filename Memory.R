library(R6)
Memory <- R6Class(
    "Memory",
    public = list(
        capacity = NULL,
        length = 0,
        states = c(),
        actions = c(),
        rewards = c(),
        dones = c(),
        states2 = c(),
        initialize = function(capacity) {
            self$capacity = capacity
        },
        push = function(s, a, r, done, s2) {
            self$states <-
                rbind(self$states, matrix(s, nrow = 1), deparse.level = 0)
            self$actions <- rbind(self$actions, a, deparse.level = 0)
            self$rewards <-
                rbind(self$rewards, r, deparse.level = 0)
            self$dones <- rbind(self$dones, done, deparse.level = 0)
            self$states2 <-
                rbind(self$states2, matrix(s2, nrow = 1), deparse.level = 0)
            self$length <- self$length + 1
            
            if (self$length > self$capacity) {
                self$states <- self$states[2:self$length, ]
                self$actions <- matrix(self$actions[2:self$length, ])
                self$rewards <- matrix(self$rewards[2:self$length, ])
                self$dones <- matrix(self$dones[2:self$length, ])
                self$states2 <- self$states[2:self$length, ]
                
                self$length <- self$length - 1L
            }
        },
        
        sample = function(batch_size) {
            if (self$length < batch_size) {
                FALSE
            } else {
                idx <- sample.int(self$length, size = batch_size)
                s <- self$states[idx, ]
                a <- matrix(self$actions[idx, ])
                r <- matrix(self$rewards[idx, ])
                d <- matrix(self$dones[idx, ])
                s2 <- self$states2[idx, ]
                
                list(
                    states = s,
                    actions = a,
                    rewards = r,
                    dones = d,
                    states2 = s2
                )
            }
        }
    )
)


memory <- Memory$new(capacity = 100)

for (i in 1:100) {
    s <- runif(4)
    a <- sample.int(2, size = 1) - 1L
    r <- sample(-10:10, size = 1)
    d <- sample(c(T, F), size = 1)
    s2 <- runif(4)
    memory$push(s, a, r, d, s2)
}
memory$sample(4)
