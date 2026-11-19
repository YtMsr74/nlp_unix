import gensim
import re
import numpy as np

pat = re.compile("(.*)_NOUN")
target_a = "пергамент_NOUN"
target_b = "полиэтилен_NOUN"
word2vec = gensim.models.KeyedVectors.load_word2vec_format("cbow.txt", binary=False)

def normalize_word(w):
    w = w.strip()
    if w in word2vec.key_to_index:
        return w
    if w + "_NOUN" in word2vec.key_to_index:
        return w + "_NOUN"
    return w

while True:
    pos_input = input("pos: ").strip()
    if pos_input == "":
        break
    neg_input = input("neg: ").strip()
    if neg_input == "":
        break
    pos = [normalize_word(pos_input)]
    neg = [normalize_word(neg_input)]

    dist = word2vec.most_similar(positive=pos, negative=neg, topn=2000)
    words = [w for w, _ in dist if pat.match(w)]
    for t in (target_a, target_b):
        print(t, words.index(t)+1 if t in words else None)
    nouns = words[:10]

    for w in nouns:
        print(pat.match(w).group(1))

    for i in (target_a, target_b):
        m = "попал" if i in nouns else "не попал"
        print(f"{pat.match(i).group(1)}: {m} в первую десятку")

    q = np.mean([word2vec[w] for w in pos], axis=0) - np.mean([word2vec[w] for w in neg], axis=0)
    q = q / np.linalg.norm(q)

    for t in (target_a, target_b):
        v = word2vec[t]
        v = v / np.linalg.norm(v)
        cos = float(np.dot(q, v))
        print(f"{pat.match(t).group(1)}: cos = {cos:.4f}")
    print("")