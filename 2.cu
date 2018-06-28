#include <iostream>

__global__ void vectorAdd(int *a, int *b, int *c, int n){
	int i = blockIdx.x*blockDim.x+threadIdx.x;
	if(i<n)
		for(int j=0;j<100;j++)
			c[i] = a[i] + b[i];
}

int main(void){
	int * a, * b, * c;
	int * d_a, * d_b, * d_c;
	int * temp;
	int n = 1<<24;

	a = new int[n*sizeof(int)];
	b = new int[n*sizeof(int)];
	c = new int[n*sizeof(int)];
	temp = new int[n*sizeof(int)];

	cudaMalloc(&d_a, n*sizeof(int));
       	cudaMalloc(&d_b, n*sizeof(int));
	cudaMalloc(&d_c, n*sizeof(int));

	for(int i=0;i<n;i++){
		a[i] = 3;
		b[i] = 5;
	}

	int blockSize = 256;
	int numBlocks = n/256;

	cudaMemcpy(d_a, a, n*sizeof(int), cudaMemcpyHostToDevice);
	cudaMemcpy(d_b, b, n*sizeof(int), cudaMemcpyHostToDevice);
	vectorAdd<<<numBlocks,blockSize>>>(d_a,d_b,d_c,n);
	cudaDeviceSynchronize();

	temp[0] = a[0];
	for(int i=1;i<n;i++)
		temp[i] = temp[i-1]+a[i];

	vectorAdd<<<numBlocks, blockSize>>>(d_a,d_b,d_c,n);
	cudaDeviceSynchronize();

	temp[0] = a[0];
	for(int i=1;i<n;i++)
		temp[i] = temp[i-1]+a[i];
	temp[0] = b[0];
	for(int i=1;i<n;i++)
		temp[i] = temp[i-1]+b[i];

	vectorAdd<<<numBlocks, blockSize>>>(d_a,d_b,d_c,n);
	cudaDeviceSynchronize();

	cudaMemcpy(c, d_c, n*sizeof(int), cudaMemcpyDeviceToHost);	
	temp[0] = c[0];
	for(int i=1;i<n;i++)
		temp[i] = temp[i-1]+c[i];

	vectorAdd<<<numBlocks, blockSize>>>(d_a,d_b,d_c,n);
	cudaDeviceSynchronize();

	vectorAdd<<<numBlocks, blockSize>>>(d_a,d_b,d_c,n);
	cudaDeviceSynchronize();

	cudaFree(a);
	cudaFree(b);
	cudaFree(c);
	delete temp;

	return 0;
}
