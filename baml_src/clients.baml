// Learn more about clients at https://docs.boundaryml.com/docs/snippets/clients/overview

client<llm> Deepseek {
  provider "openai-generic"

  options {

    base_url env.OLLAMA_BASE_URL

    model deepseek-r1:7b

  }
}

client<llm> Gemini {
  provider google-ai
  options {
    model "gemini-1.5-flash"
  }
}

// https://docs.boundaryml.com/docs/snippets/clients/retry
retry_policy Constant {
  max_retries 3
  // Strategy is optional
  strategy {
    type constant_delay
    delay_ms 200
  }
}

retry_policy Exponential {
  max_retries 2
  // Strategy is optional
  strategy {
    type exponential_backoff
    delay_ms 300
    mutliplier 1.5
    max_delay_ms 10000
  }
}
