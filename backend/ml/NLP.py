import numpy as np
from transformers import pipeline


class StockNewsSentimentAnalyzer:
    def __init__(self):
        # Initialize the sentiment analysis pipeline using a pre-trained model
        self.sentiment_analyzer = pipeline(
            "sentiment-analysis",
            model="finiteautomata/bertweet-base-sentiment-analysis",
            device=-1  # Use CPU. Change to 0 for GPU if available
        )
        
        # Keywords that might indicate bullish/bearish sentiment in financial context
        self.bullish_keywords = {
            'surge', 'jump', 'rise', 'gain', 'growth', 'positive', 'up', 'higher',
            'bullish', 'outperform', 'upgrade', 'buy', 'strong', 'exceed',
            'profit', 'earnings', 'beat', 'success', 'opportunity'
        }
        
        self.bearish_keywords = {
            'drop', 'fall', 'decline', 'loss', 'negative', 'down', 'lower',
            'bearish', 'underperform', 'downgrade', 'sell', 'weak', 'miss',
            'deficit', 'risk', 'concern', 'warning', 'trouble'
        }

    def analyze_sentiment(self, news_text):
        """
        Analyze the sentiment of stock news text.
        
        Args:
            news_text (str): The news text to analyze
            
        Returns:
            dict: A dictionary containing:
                - sentiment: 'BULLISH' or 'BEARISH'
                - confidence: float between 0 and 1
                - score: float between -1 and 1
                - keywords_found: list of relevant keywords found
        """
        # Get the base sentiment analysis
        result = self.sentiment_analyzer(news_text)[0]
        
        # Convert the label to our format
        base_sentiment = result['label'].upper()
        confidence = result['score']
        
        # Count bullish and bearish keywords
        text_lower = news_text.lower()
        bullish_count = sum(1 for word in self.bullish_keywords if word in text_lower)
        bearish_count = sum(1 for word in self.bearish_keywords if word in text_lower)
        
        # Calculate keyword-based sentiment score (-1 to 1)
        keyword_score = (bullish_count - bearish_count) / (bullish_count + bearish_count + 1)
        
        # Combine base sentiment with keyword analysis
        if base_sentiment == 'POSITIVE':
            base_score = 0.5
        elif base_sentiment == 'NEGATIVE':
            base_score = -0.5
        else:
            base_score = 0
            
        # Final score is weighted average of base sentiment and keyword analysis
        final_score = (base_score * 0.7) + (keyword_score * 0.3)
        
        # Determine final sentiment
        sentiment = 'BULLISH' if final_score > 0 else 'BEARISH'
        
        # Get found keywords
        found_keywords = []
        for word in self.bullish_keywords:
            if word in text_lower:
                found_keywords.append(word)
        for word in self.bearish_keywords:
            if word in text_lower:
                found_keywords.append(word)
        
        return {
            'sentiment': sentiment,
            'confidence': confidence,
            'score': final_score,
            'keywords_found': found_keywords
        }

    def analyze_multiple_news(self, news_list):
        """
        Analyze sentiment for multiple news items.
        
        Args:
            news_list (list): List of news texts
            
        Returns:
            list: List of sentiment analysis results
        """
        results = []
        for news in news_list:
            result = self.analyze_sentiment(news)
            results.append(result)
        return results

# Example usage
if __name__ == "__main__":
    analyzer = StockNewsSentimentAnalyzer()
    
    # Example news
    news = "Stock prices surged after company reported strong earnings, exceeding market expectations"
    result = analyzer.analyze_sentiment(news)
    print(f"News: {news}")
    print(f"Sentiment: {result['sentiment']}")
    print(f"Confidence: {result['confidence']:.2f}")
    print(f"Score: {result['score']:.2f}")
    print(f"Keywords found: {result['keywords_found']}")
