String cancellationErrorJson(String transactionId) => """
    {
      "errorCode": 2,
      "reason": "Operation cancelled",
      "transactionId": "$transactionId"
    }
    """;
