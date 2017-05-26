library(R6)
library(tensorflow)

Agent <- R6Class(
    "Agent",
    public = list(
        input_shape = NULL,
        output_dim = NULL,
        epsilon = 1.0,
        states = NULL,
        Q_target = NULL,
        pred = NULL,
        loss = NULL,
        train_op = NULL,
        epsilon_last_episode = 100,
        initialize = function(input_shape,
                              output_dim,
                              epsilon_last_episode = NULL) {
            self$input_shape <- input_shape
            self$output_dim <- output_dim
            if (!is.null(epsilon_last_episode)) {
                self$epsilon_last_episode <- epsilon_last_episode
            }
            self$states <-
                tf$placeholder(tf$float32,
                               shape = shape(NULL, input_shape),
                               name = "states")
            self$Q_target <-
                tf$placeholder(tf$float32,
                               shape = shape(NULL, output_dim),
                               name = "Q_target")
            
            with(tf$variable_scope("layer1"), {
                net <- self$states
                net <- tf$layers$dense(net,
                                       units = 32L,
                                       activation = tf$nn$relu)
            })
            with(tf$variable_scope("layer2"), {
                net <- tf$layers$dense(net,
                                       units = 32L,
                                       activation = tf$nn$relu)
            })
            self$pred <-
                tf$layers$dense(net, units = self$output_dim)
            self$loss <-
                tf$reduce_mean(tf$squared_difference(self$pred, self$Q_target))
            
            optim <- tf$train$AdamOptimizer()
            self$train_op <- optim$minimize(self$loss)
        },
        
        get_action = function(state_, step) {
            if (runif(1) < self$epsilon) {
                action <- sample.int(self$output_dim, size = 1) - 1L
            } else {
                sess <- tf$get_default_session()
                states <- self$states
                feed <-
                    dict(states = matrix(state_, nrow = 1, byrow = TRUE))
                action_probs <- sess$run(self$pred, feed)
                action <- which.max(action_probs) - 1L
            }
            
            self$epsilon <-
                max(0.01, -1 / self$epsilon_last_episode * step + 1.0)
            action
        },
        
        predict = function(states_) {
            sess <- tf$get_default_session()
            states <- self$states
            feed <- dict(states = states_)
            sess$run(self$pred, feed)
        },
        
        train = function(states_, targets_) {
            states <- self$states
            Q_target <- self$Q_target
            
            feed <- dict(states = states_,
                         Q_target = targets_)
            sess <- tf$get_default_session()
            sess$run(self$train_op, feed)
        }
    )
)

tf$reset_default_graph()
agent <- Agent$new(4, 2)
s <- matrix(c(1, 1, 1, 1), nrow = 1, byrow = T)
with(tf$Session() %as% sess, {
    init <- tf$global_variables_initializer()
    sess$run(init)
    agent$get_action(s, 0.0)
})
