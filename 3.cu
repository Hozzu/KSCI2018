#include <iostream>

__global__ void vectorAdd(int *a, int *b, int *c, int n){
	int i = blockIdx.x*blockDim.x+threadIdx.x;
	if(i<n)
		for(int j=0;j<100;j++)
			c[i] = a[i] + b[i];
}

int main(void){
	int * a, * b;
	int * r1, * r2, *r3;
	int * temp;
	const int n = 1<<24;
	const int n_s = 3;

	cudaStream_t streams[n_s];
	for(int i=0;i<n_s;i++)
		cudaStreamCreate(&streams[i]);

	cudaMallocManaged(&a, n*sizeof(int));
       	cudaMallocManaged(&b, n*sizeof(int));
	cudaMallocManaged(&r1, n*sizeof(int));
	cudaMallocManaged(&r2, n*sizeof(int));
	cudaMallocManaged(&r3, n*sizeof(int));
	temp = new int[n*sizeof(int)];

	for(int i=0;i<n;i++){
		a[i] = 3;
		b[i] = 5;
	}

	int blockSize = 256;
	int numBlocks = n/256;
	
	vectorAdd<<<numBlocks,blockSize,0,streams[0]>>>(a,a,r1,n);
	
	vectorAdd<<<numBlocks, blockSize,0,streams[1]>>>(b,b,r2,n);
	
	vectorAdd<<<numBlocks, blockSize,0,streams[2]>>>(a,b,r3,n);

	cudaDeviceSynchronize();
	temp[0] = r1[0];
	for(int i=1;i<n;i++)
		temp[i] = temp[i-1] + r1[i];
	cudaDeviceSynchronize();
	temp[0] = r2[0];
	for(int i=1;i<n;i++)
		temp[i] = temp[i-1] + r2[i];
	cudaDeviceSynchronize();
	temp[0] = r3[0];
	for(int i=1;i<n;i++)
		temp[i] = temp[i-1] + r3[i];

	cudaFree(a);
	cudaFree(b);
	cudaFree(r1);
	cudaFree(r2);
	cudaFree(r3);
	delete [] temp;
	
	return 0;
}
