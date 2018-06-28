#include <iostream>

__global__ void vectorAdd(int *a, int *b, int *c, int n){
	int i = blockIdx.x*blockDim.x+threadIdx.x;
	if(i<n)
		for(int j=0;j<100;j++)
			c[i] = c[i] + a[i]*b[i];
}

int main(void){
	int * a, * b;
	int * d_a, * d_b;
	int * d_r1, * d_r2, *d_r3;
	int * temp, * temp2;
	const int n = 1<<24;
	const int n_s = 3;

	cudaStream_t streams[n_s];
	for(int i=0;i<n_s;i++)
		cudaStreamCreate(&streams[i]);

	a = new int[n*sizeof(int)];
	b = new int[n*sizeof(int)];
	temp = new int[n*sizeof(int)];
	temp2 = new int[n*sizeof(int)];

	cudaMalloc(&d_a, n*sizeof(int));
       	cudaMalloc(&d_b, n*sizeof(int));
	cudaMalloc(&d_r1, n*sizeof(int));
	cudaMalloc(&d_r2, n*sizeof(int));
	cudaMalloc(&d_r3, n*sizeof(int));

	for(int i=0;i<n;i++){
		a[i] = 3;
		b[i] = 5;
	}

	int blockSize = 256;
	int numBlocks = n/256;
	
	cudaMemcpyAsync(d_a, a, n*sizeof(int), cudaMemcpyHostToDevice, streams[0]);
	vectorAdd<<<numBlocks,blockSize,0,streams[0]>>>(d_a,d_a,d_r1,n);

	cudaMemcpyAsync(d_b, b, n*sizeof(int), cudaMemcpyHostToDevice, streams[1]);
	vectorAdd<<<numBlocks, blockSize,0,streams[1]>>>(d_b,d_b,d_r2,n);

	vectorAdd<<<numBlocks, blockSize,0,streams[2]>>>(d_a,d_b,d_r3,n);
	
	cudaMemcpyAsync(temp, d_r1, n*sizeof(int), cudaMemcpyDeviceToHost, streams[0]);
	cudaDeviceSynchronize();
	temp2[0] = temp[0];
	for(int i=1;i<n;i++)
		temp2[i] = temp2[i-1] + temp[i];
	cudaMemcpyAsync(temp, d_r2, n*sizeof(int), cudaMemcpyDeviceToHost, streams[1]);
	cudaDeviceSynchronize();
	temp2[0] = temp[0];
	for(int i=1;i<n;i++)
		temp2[i] = temp2[i-1] + temp[i];
	cudaMemcpyAsync(temp, d_r3, n*sizeof(int), cudaMemcpyDeviceToHost, streams[2]);	
	cudaDeviceSynchronize();
	temp2[0] = temp[0];
	for(int i=1;i<n;i++)
		temp2[i] = temp2[i-1] + temp[i];

	cudaFree(d_a);
	cudaFree(d_b);
	cudaFree(d_r1);
	cudaFree(d_r2);
	cudaFree(d_r3);
	delete a;
	delete b;
	delete [] temp;
	delete [] temp2;

	return 0;
}
