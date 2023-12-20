#include <stdlib.h>
#include <stdio.h>
#include <math.h>

double sigmoid(double x) { return 1.0f / (1.0f + exp(-x)); }
double sigmoid_derivative(double x) { return x * (1.0f - x); }
double init_weights() { return (double)rand() / (double)RAND_MAX; }

void shuffle(int *array, size_t n)
{
    if (n > 1)
    {
        size_t i;
        for (i = 0; i < n - 1; i++)
        {
            size_t j = i + rand() / (RAND_MAX / (n - i) + 1);
            int t = array[j];
            array[j] = array[i];
            array[i] = t;
        }
    }
}

#define number_of_inputs 2
#define number_of_hidden_nodes 2
#define number_of_outputs 1
#define number_of_training_sets 4

/*
    A simple neural network that can learn the XOR function
*/

int main(void)
{
    const double learning_rate = 0.1f;

    double hidden_layer[number_of_hidden_nodes];
    double output_layer[number_of_outputs];

    double hiiden_layer_bias[number_of_hidden_nodes];
    double output_layer_bias[number_of_outputs];

    double hidden_layer_weights[number_of_inputs][number_of_hidden_nodes];
    double output_layer_weights[number_of_hidden_nodes][number_of_outputs];

    double training_inputs[number_of_training_sets][number_of_inputs] = {{0.0f, 0.0f}, {0.0f, 1.0f}, {1.0f, 0.0f}, {1.0f, 1.0f}};
    double training_outputs[number_of_training_sets][number_of_outputs] = {{0.0f}, {1.0f}, {1.0f}, {0.0f}};

    for(int i = 0; i < number_of_inputs; i++)
    {
        for(int j = 0; j < number_of_hidden_nodes; j++)
        {
            hidden_layer_weights[i][j] = init_weights();
        }
    }

    for(int i = 0; i < number_of_hidden_nodes; i++)
    {
        for(int j = 0; j < number_of_outputs; j++)
        {
            output_layer_weights[i][j] = init_weights();
        }
    }

    for(int i = 0; i < number_of_hidden_nodes; i++)
    {
        hiiden_layer_bias[i] = init_weights();
    }

    int training_set_order[] = {0, 1, 2, 3};

    int number_of_epochs = 10000;

    // Train the neural network for a number of epochs

    for (int epoch = 0; epoch < number_of_epochs; epoch++)
    {
        shuffle(training_set_order, number_of_training_sets);

        for (int x = 0; x < number_of_training_sets; x++)
        {
            int i = training_set_order[x];

            // Forward pass

            // Calculate hidden layer activation
            for (int j = 0; j < number_of_hidden_nodes; j++)
            {
                double activation = hiiden_layer_bias[j];

                for (int k = 0; k < number_of_inputs; k++)
                {
                    activation += training_inputs[i][k] * hidden_layer_weights[k][j];
                }

                hidden_layer[j] = sigmoid(activation);
            }

            // Calculate output layer activation
            for (int j = 0; j < number_of_outputs; j++)
            {
                double activation = output_layer_bias[j];

                for (int k = 0; k < number_of_hidden_nodes; k++)
                {
                    activation += hidden_layer[k] * output_layer_weights[k][j];
                }

                output_layer[j] = sigmoid(activation);
            }

            printf("Input: %f %f, Expected: %f, Output: %f\n", training_inputs[i][0], training_inputs[i][1], training_outputs[i][0], output_layer[0]);

            // Backward pass

            // Calculate change in output layer weights

            double delta_output_weights[number_of_outputs];

            for (int j = 0; j < number_of_outputs; j++)
            {
                double error = (training_outputs[i][j] - output_layer[j]);
                delta_output_weights[j] = error * sigmoid_derivative(output_layer[j]);
            }

            // Calculate change in hidden layer weights

            double delta_hidden_weights[number_of_hidden_nodes];

            for (int j = 0; j < number_of_hidden_nodes; j++)
            {
                double error = 0.0f;

                for (int k = 0; k < number_of_outputs; k++)
                {
                    error += delta_output_weights[k] * output_layer_weights[j][k];
                }

                delta_hidden_weights[j] = error * sigmoid_derivative(hidden_layer[j]);
            }

            // Apply changes to output weights

            for (int j = 0; j < number_of_outputs; j++)
            {
                output_layer_bias[j] += delta_output_weights[j] * learning_rate;

                for (int k = 0; k < number_of_hidden_nodes; k++)
                {
                    output_layer_weights[k][j] += hidden_layer[k] * delta_output_weights[j] * learning_rate;
                }
            }

            // Apply changes to hidden weights

            for (int j = 0; j < number_of_hidden_nodes; j++)
            {
                hiiden_layer_bias[j] += delta_hidden_weights[j] * learning_rate;

                for (int k = 0; k < number_of_inputs; k++)
                {
                    hidden_layer_weights[k][j] += training_inputs[i][k] * delta_hidden_weights[j] * learning_rate;
                }
            }

        }
    }

    fputs("Final Hidden Weights: [", stdout);
    for (int j = 0; j < number_of_inputs; j++)
    {
        fputs("[", stdout);
        for (int k = 0; k < number_of_hidden_nodes; k++)
        {
            printf("%f ", hidden_layer_weights[j][k]);
        }
        fputs("]", stdout);
    }

    fputs("]\nFinal Hidden Bias: [", stdout);
    for (int j = 0; j < number_of_hidden_nodes; j++)
    {
        printf("%f ", hiiden_layer_bias[j]);
    }

    fputs("]\nFinal Output Weights: [", stdout);
    for (int j = 0; j < number_of_hidden_nodes; j++)
    {
        fputs("[", stdout);
        for (int k = 0; k < number_of_outputs; k++)
        {
            printf("%f ", output_layer_weights[j][k]);
        }
        fputs("]", stdout);
    }

    fputs("]\nFinal Output Bias: [", stdout);
    for (int j = 0; j < number_of_outputs; j++)
    {
        printf("%f ", output_layer_bias[j]);
    }
    
    fputs("]\n\n", stdout);

    return 0;
}