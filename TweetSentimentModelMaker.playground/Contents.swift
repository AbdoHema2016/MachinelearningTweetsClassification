import Cocoa
import CreateML

if #available(OSX 10.14, *) {
    let data = try MLDataTable(contentsOf: URL(fileURLWithPath: "/Users/abdelrahman-arw/Desktop/iOS/MLStockPrediction/ArabicSentimentAnalysisDataset-SS2030.csv"))
    let(trainingData, testingData) = data.randomSplit(by: 0.8, seed: 5)
    let sentimentClassifier = try MLTextClassifier(trainingData: trainingData, textColumn: "text", labelColumn: "class")
    let evaluationMatrics = sentimentClassifier.evaluation(on: testingData)
    let evaluationAccuracy = (1.0 - evaluationMatrics.classificationError) * 100
    let metadata = MLModelMetadata(author: "Abdo", shortDescription: "A Model trained to classify tweets impressions to positive and negative", version: "1.0")
    try sentimentClassifier.write(to: URL(fileURLWithPath: "/Users/abdelrahman-arw/Desktop/iOS/MLStockPrediction/ArabicTweetSentimentClassifier.mlmodel"))
} else {
    // Fallback on earlier versions
    print("hello")
}

