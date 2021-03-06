library(tidyverse)
library(haven)
library(ggthemes)

dat <- read_sav("DATACOLLECTIONPHYSICAL.sav") 

(dat %>%
	mutate(person = as.factor(1:nrow(dat))) %>%
	select(person, Condition, 
		PositionCHoopTrial1, PositionCHoopTrial2, PositionCHoopTrial3,
		PositionMHoopTrial1, PositionMHoopTrial2, PositionMHoopTrial3,
		PositionFHoopTrial1, PositionFHoopTrial2, PositionFHoopTrial3
		) %>%
	rename(condition = "Condition") %>%
	gather("hoop", "standing_position", -condition, -person) %>%
	mutate(
		condition = as_factor(condition),
		hoop = as_factor(hoop),
		hoop = fct_collapse(hoop, 
			close = c("PositionCHoopTrial1", "PositionCHoopTrial2", "PositionCHoopTrial3"),
			med   = c("PositionMHoopTrial1", "PositionMHoopTrial2", "PositionMHoopTrial3"),
			far   = c("PositionFHoopTrial1", "PositionFHoopTrial2", "PositionFHoopTrial3"))
		)) -> dat 

dat$distance <- as.numeric(dat$hoop)
dat$distance[which(dat$distance == 2)] <- 4.5
dat$distance[which(dat$distance == 3)] <- 7.0

levels(dat$condition) <- c("Reaching Task", "Logic Puzzles", "Maths Questions")

(dat %>% 
	mutate(standing_position = standing_position / distance) -> dat
summary(dat)


plt <- ggplot(dat, aes(x = distance, y = standing_position, colour = condition))
plt <- plt + geom_point(alpha = 0.5)
plt <- plt + facet_wrap(~person, nrow = 3)
plt <- plt + scale_colour_manual(values = c("#CC6677", "#4477AA", "#117733"))
plt <- plt + theme_bw()
plt <- plt + scale_x_continuous("Delta (metres)")
plt <- plt + scale_y_continuous("Normalised Standing Position")
plt

ggsave('standing_position.pdf', width = 8, height = 6)
ggsave('standing_position.png', width = 8, height = 6)



# now look at accuracy

dat <- read_sav("DATACOLLECTIONPHYSICAL.sav") 

(dat %>%
	mutate(person = as.factor(1:nrow(dat))) %>%
	select(person, Condition, 
		AccuracyCHoopTrial1, AccuracyCHoopTrial2, AccuracyCHoopTrial3,
		AccuracyMHoopTrial1, AccuracyMHoopTrial2, AccuracyMHoopTrial3,
		AccuracyFHoopTrial1, AccuracyFHoopTrial2, AccuracyFHoopTrial3
		) %>%
	rename(condition = "Condition") %>%
	gather("hoop", "accuracy", -condition, -person) %>%
	mutate(
		condition = as_factor(condition),
		hoop = as_factor(hoop),
		hoop = fct_collapse(hoop, 
			close = c("AccuracyCHoopTrial1", "AccuracyCHoopTrial2", "AccuracyCHoopTrial3"),
			med   = c("AccuracyMHoopTrial1", "AccuracyMHoopTrial2", "AccuracyMHoopTrial3"),
			far   = c("AccuracyFHoopTrial1", "AccuracyFHoopTrial2", "AccuracyFHoopTrial3"))
		) %>%
	group_by(person, condition) %>%
	summarise(accuracy = mean(accuracy))) -> dat 

levels(dat$condition) <- c("Reaching Task", "Logic Puzzles", "Maths Questions")


plt <- ggplot(dat, aes(x = condition, y = accuracy, fill = condition))
plt <- plt + geom_boxplot()
plt <- plt + scale_colour_manual(values = c("#CC6677", "#4477AA", "#117733"))
plt <- plt + theme_bw()
plt <- plt + scale_x_discrete("condition")
plt <- plt + theme(legend.position = "none")
plt <- plt + scale_y_continuous("Accuracy", limits = c(0, 1), expand = c(0,0))
ggsave("accuracy.png", width = 4, height = 3)
# m <- aov(data = filter(dat, hoop == "far"), mean_standing_pos ~ condition)

# # try a needlessly crazy beta regression model

# dat$mean_standing_pos[which(dat$mean_standing_pos == 1)] = 0.95
# dat$mean_standing_pos[which(dat$mean_standing_pos == 0)] = 0.05

# library(rethinking)

# dat %>% 
#   mutate(
#     did_logic = if_else(condition == "LogicPuzzle", 1, 0),
#     did_reach = if_else(condition == "LogicPuzzle", 1, 0)) -> dat




# m <- map2stan(
#   alist(
#     mean_standing_pos ~ dbeta(p * theta, (1 - p) * theta),
#     logit(p) <- a + b_logic * did_logic + b_reach * did_reach,		
#     a ~ dnorm(0, 1),
#     b_logic ~ dnorm(0, 1),
#     b_reach ~ dnorm(0, 1),
#     theta ~ dcauchy(0, 1)),
#   start = list(theta =1),
#   data = as.data.frame(dat), 
#   iter = 1000, warmup = 1000, chains = 2)


# n = 1000
# post <- extract.samples(m, n  = n)

# pdat <- tibble(
#   maths = post$a,
#   logic = post$a + post$b_logic,
#   reach = post$a + post$b_reach) %>%
#     gather(condition, p) %>% mutate(p = logistic(p))


# pdat$theta <- rep(post$theta, 3)

# pdat$condition <- as_factor(pdat$condition, "maths", "logic", "reach")

# library(viridisLite)
# plt <- ggplot(pdat, aes(x = p, fill = condition)) + geom_density(alpha = 0.5)
# plt <- plt + theme_bw() + scale_fill_viridis_d()
# plt <- plt + scale_x_continuous("posterior for mean standing position",
# limits = c(0, 1), expand = c(0, 0))
# ggsave("estimate_of_mean_standing_pos.png", height = 4, width = 4)





# # redo for accuracy instead of standing position!



# # dat <- read_sav("DATACOLLECTIONPHYSICAL.sav") 

# # (dat %>%
#     mutate(person = 1:nrow(dat)) %>%
#     select(person, Condition, 
#            AccuracyCHoopTrial1, AccuracyCHoopTrial2, AccuracyCHoopTrial3,
#            AccuracyMHoopTrial1, AccuracyMHoopTrial2, AccuracyMHoopTrial3,
#            AccuracyFHoopTrial1, AccuracyFHoopTrial2, AccuracyFHoopTrial3
#     ) %>%
#     rename(condition = "Condition") %>%
#     gather("hoop", "accuracy", -condition, -person) %>%
#     mutate(
#       condition = as_factor(condition),
#       hoop = as_factor(hoop),
#       hoop = fct_collapse(hoop, 
#                           close = c("AccuracyCHoopTrial1", "AccuracyCHoopTrial2", "AccuracyCHoopTrial3"),
#                           med   = c("AccuracyMHoopTrial1", "AccuracyMHoopTrial2", "AccuracyMHoopTrial3"),
#                           far   = c("AccuracyFHoopTrial1", "AccuracyFHoopTrial2", "AccuracyFHoopTrial3"))
#     )) -> dat 

# dat$distance <- as.numeric(dat$hoop)
# dat$distance[which(dat$distance == 2)] <- 4.5
# dat$distance[which(dat$distance == 3)] <- 7.0

# #remove accuracy == 2 Why is this here? Coding mistake I assume


# dat %>% 
#     filter(accuracy %in% c(0, 1)) %>% 
#   mutate(
#     did_logic = if_else(condition == "LogicPuzzle", 1, 0),
#     did_reach = if_else(condition == "LogicPuzzle", 1, 0)) -> dat



# dat <- as.data.frame(dat)


# m <- map2stan( 
#   alist(
#     accuracy ~ dbinom(1, p),
#     logit(p) <- a + a_p[person] + b_logic * did_logic + b_reach * did_reach,
#     a ~ dnorm(0, 1),
#     b_logic ~ dnorm(0, 1),
#     b_reach ~ dnorm(0, 1),
#     a_p[person] ~ dnorm(0, sigma_p),
#     sigma_p ~ dcauchy(0, 1)),
#   data = filter(dat, hoop == "far"))



# post <- extract.samples(m)

# fx <- tibble(
#   condition = rep(c(
#     "Maths", 
#     "Logic", 
#     "Reaching"), each = length(post$a)),
#   samples = c(
#     logistic(post$a), 
#     logistic(post$a + post$b_logic), 
#     logistic(post$a + post$b_reach)))



# plt <- ggplot(fx, aes(x = samples, fill = condition))
# plt <- plt + geom_density(alpha = 0.5)
# plt <- plt + theme_bw()  + scale_fill_viridis_d()
# plt <- plt + scale_x_continuous(
#   name = "probablity of throwing beanbag into the far hoop", limits = c(0, 1), expand = c(0,0))
# plt
# ggsave("JessieData.pdf")

