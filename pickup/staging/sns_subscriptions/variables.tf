variable "topics" {
    type = set(string)
    description = "A set of names of topics to subscribe to"
    default = ["partner-updates-staging"]
}