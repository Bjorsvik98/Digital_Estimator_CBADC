def check(A, B, samples, start=0, offset=0):
    # Check each element in the list if they are equal and print the elements that are not equal
    correct = 0
    wrong = 0
    for i in range(0, samples):
        # print("A[",i,"]", A[i], "B[",i,"]", B[i+offset])   
        # print("A[%d] = %d, B[%d] = %d" % (i, A[i], i, B[i]))
        # if A[i+start] != B[i+start+offset]:
        if A[i] != B[i]:
            wrong += 1
        else:
            correct += 1
    return correct, wrong
    