%{
    title: "A partially wrong TF-IDF in Flix",
    tags: ~w(tf-idf natural-language-processing flix side-project retrospective),
    date_created: "2024-05-05",
}
---
Recently I reminded myself of TF-IDF and the relatively simplicity of it, in and of itself. Having considered a Python implementation, and wanting to write _something_ in Flix[^1][^2], I thought this could be a good opportunity.

Why is it _partially_ wrong? Well, because I wrote it, wasn't 100% happy with the results, but the intent was to quickly try something in Flix!

Here it is:

```flix
type alias ID = String
type alias Body = String
type alias Document = {id = ID, body = Body}

type alias Token = String

type alias Corpus = List[Document]

type alias IDF = Float64
type alias TF = Map[ID, Int32]
type alias TF_IDF = Float64
type alias Entry = {
    idf = IDF,
    tf = TF
}
type alias Index = Map[Token, Entry]

def idf(n: Int32, tf: TF): Float64 =
    import static java.lang.Math.log(Float64): Float64 \ {};

    ((n / Map.size(tf)) + 1)
    |> Int32.toFloat64
    |> log


def incrementFrequency(id: ID, tf: TF): TF =
    Map.insertWith(
        (_new, old) -> old + 1, // Increment the frequency of the term
        id,
        1, // Initial frequency
        tf
    )

def nextTerm(id: ID, index: Index, term: String): Index =
    let default: Entry = {idf = 0.0, tf = Map#{id => 1}};

    Map.insertWith(
        // Update the entry for the term, if is present in the index
        (_new, old) -> { tf = incrementFrequency(id, old.tf)  | old}, // Retain the old IDF
        term, // Term as a key
        default, // In case term isn't present in the index
        index
    )

def nextDoc(index: Index, document: Document): Index =
    let appNextTerm = nextTerm(document.id);
    let tokens = sentenceToTokens(document.body);

    List.foldLeft(appNextTerm, index, tokens)

def sentenceToTokens(sentence: String): List[String] =
    sentence
    |> String.toLowerCase
    |> String.splitOn({substr = " "})

def buildTf(corpus: Corpus): Index =
    let index = Map.empty(); // Initialise an empty index

    List.foldLeft(nextDoc, index, corpus)

def buildIdf(n: Int32, index: Index): Index =
    Map.map(entry -> { idf = idf(n, entry.tf) | entry }, index)

pub def buildIndex(corpus: Corpus): Index =
    let n = List.length(corpus); // Compute this once

    corpus
    |> buildTf
    |> buildIdf(n)

def retrieve(index: Index, query: String, top_k: Int32): List[(ID, Float64)] =
    let tokens = sentenceToTokens(query);
    let initialDocScores: Map[ID, Float64] = Map.empty();

    tokens
    |> List.foldLeft(
        (docScores, token) ->
            match Map.get(token, index) {
                case None => docScores
                case Some(entry) =>
                    let docTfIdfs = Map.map(termFreq -> Int32.toFloat64(termFreq) * entry.idf, entry.tf);

                    Map.intersectionWith(
                        (score1, score2) -> score1 + score2,
                        docScores,
                        docTfIdfs
                    )
            },
        initialDocScores
    )
    |> Map.toList
    |> List.sortBy(val -> snd(val))
    |> List.take(top_k)

def main(): Unit \ IO =
    let corpus: Corpus =
        {id = "aaaa", body = "Hello Giraffe one and giraffe 2"} ::
        {id = "bbbb", body = "There are lots of animals, like giraffes"} ::
        {id = "cccc", body = "Why are there lots of animals"} ::
        Nil;
    let index: Index = debug(buildIndex(corpus));
    let query = "where is the giraffe on the moon?";

    println(retrieve(index, query, 5))
```

[^1]: [Flix](https://flix.dev)

[^2]: Beyond a previous [experiment](programming-imperative-to-functional-to-logic) trying logic programming with it
