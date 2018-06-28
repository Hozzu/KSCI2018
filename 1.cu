#include <iostream>

__global__ void vectorAdd(int *a, int *b, int *c, int n){
	int i = blockIdx.x*blockDim.x+threadIdx.x;
	if(i<n)
		for(int j=0;j<100;j++)
			c[i] = a[i] + b[i];
}

int main(void){
	int * a, * b, * c;
	int * temp;
	int n = 1<<24;

	cudaMallocManaged(&a, n*sizeof(int));
       	cudaMallocManaged(&b, n*sizeof(int));
	cudaMallocManaged(&c, n*sizeof(int));
	temp = new int[n*sizeof(int)];

	for(int i=0;i<n;i++){
		a[i] = 3;
		b[i] = 5;
	}

	int blockSize = 256;
	int numBlocks = n/256;

	vectorAdd<<<numBlocks,blockSize>>>(a,b,c,n);
	cudaDeviceSynchronize();

	temp[0] = a[0];
	for(int i=1;i<n;i++)
		temp[i] = temp[i-1] + a[i];

	vectorAdd<<<numBlocks,blockSize>>>(a,b,c,n);
	cudaDeviceSynchronize();

	temp[0] = a[0];
	for(int i=1;i<n;i++)
		temp[i] = temp[i-1] + a[i];
	temp[0] = b[0];
	for(int i=1;i<n;i++)
		temp[i] = temp[i-1] + b[i];

	vectorAdd<<<numBlocks, blockSize>>>(a,b,c,n);
	cudaDeviceSynchronize();

	temp[0] = c[0];
	for(int i=1;i<n;i++)
		temp[i] = temp[i-1] + c[i];

	vectorAdd<<<numBlocks, blockSize>>>(a,b,c,n);
	cudaDeviceSynchronize();

	vectorAdd<<<numBlocks, blockSize>>>(a,b,c,n);
	cudaDeviceSynchronize();
	
	cudaFree(a);
	cudaFree(b);
	cudaFree(c);
	delete temp;

	return 0;
}
