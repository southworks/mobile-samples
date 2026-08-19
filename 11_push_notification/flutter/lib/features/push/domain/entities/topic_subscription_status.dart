sealed class TopicSubscriptionStatus {
  const TopicSubscriptionStatus();
}

final class TopicSubscriptionUnknown extends TopicSubscriptionStatus {
  const TopicSubscriptionUnknown();
}

final class TopicSubscriptionSubscribed extends TopicSubscriptionStatus {
  const TopicSubscriptionSubscribed();
}

final class TopicSubscriptionNotSubscribed extends TopicSubscriptionStatus {
  const TopicSubscriptionNotSubscribed();
}

final class TopicSubscriptionError extends TopicSubscriptionStatus {
  const TopicSubscriptionError(this.message);

  final String message;
}

final class TopicSubscriptionInProgress extends TopicSubscriptionStatus {
  const TopicSubscriptionInProgress();
}
