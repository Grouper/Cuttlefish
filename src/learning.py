from sklearn import svm
from sklearn.svm import SVC
from sklearn.linear_model import LogisticRegression
from sklearn.tree import DecisionTreeClassifier
from sklearn.feature_selection import SelectKBest, chi2
import csv
import argparse
RESULTS_FILE = "results.txt"
            
def get_precision_recall(labels, predictions):
    tp = fp = tn = fn = 0
    for i in range(len(labels)):
        label = labels[i]
        if label == 1:
            if predictions[i] == 1:
                tp += 1
            if predictions[i] == 0:
                fn += 1
        else:
            if predictions[i] == 0:
                tn += 1
            if predictions[i] == 1:
                fp += 1
    precision = float(tp) / (tp + fp) if tp + fp > 0 else 0
    recall = float(tp) / (tp + fn) if tp + fn > 0 else 0
    return [precision, recall]

def is_number(s):
    try:
        float(s)
        return True
    except ValueError:
        return False

def get_data(filename):
    data = []
    labels = []
    reader = open(filename, 'rU')
    title_line = reader.next()
    for row in reader:
        vec = row.strip().split(",")
        result = 0 if vec[-1] == 'FALSE' else 1
        # Remove string type values ('male', 'female', 'FALSE')
        vec = [point for point in vec if is_number(point)]
        data.append(vec)
        labels.append(result)
    return [data, labels]

def get_train_data(filename):
    [data, labels] = get_data(filename)
    cutoff = int(0.8 * len(data))
    train = [data[0:cutoff], labels[0:cutoff]]
    dev = [data[cutoff:], labels[cutoff:]]
    return [train, dev]

def get_test_data(filename):
    return get_data(filename)
    
def evaluate(predictions, labels, name):
    print "------Results for " + name + " model------------"
   
    precision, recall = get_precision_recall(labels, predictions)
    print "precision: " + str(precision)
    print "recall: " + str(recall)

    F1 = (2.0 * precision * recall) / (precision + recall) if precision + recall > 0 else 0
    print "F1: " + str(F1)

def run_subset(trainComments, trainLabels, sampleSize):
     pass

    #print "-------------MaxEnt predictions-----------------"

    #results = maxent.predict(matrix_test)
    #result_probs = maxent.predict_proba(matrix_test)
    #print results
    #evaluate(dev_sentences, results, dev_labels, "SVM", features, result_probs)

def main(train_file, test_file):
    train_data, dev_data = get_train_data(train_file)
    train_instances, train_labels = train_data
    dev_instances, dev_labels = dev_data

    test_instances = get_test_data(test_file)

    print "Creating SVM..."
    clf1 = svm.SVC(kernel='linear', probability=True)
    print "Training algorithm using " + str(len(train_instances)) + " instances..."
    clf1.fit(train_instances, train_labels)
    print "Predicting " + str(len(dev_instances)) + " new instances..."
    predictions = clf1.predict(dev_instances)
    print "Generating probabilities for new instances..."
    #result_probs = clf1.predict_proba(dev_instances)

    print "Evaluating performance..."
    evaluate(predictions, dev_labels, "SVM")
    #print result_probs

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Download content for domain-specific wiki app', epilog='')
    parser.add_argument("--train", help='CSV file specifying training data', required=True)
    parser.add_argument("--test", help='CSV file specifying test data', required=True)
    args = parser.parse_args()
    main(args.train, args.test)
