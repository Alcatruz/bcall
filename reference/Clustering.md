# Clustering R6 Class (Internal)

Internal R6 class for automatic legislator clustering. Users should use
bcall_auto() instead.

## Public fields

- `N`:

  Distance metric (1=Manhattan, 2=Euclidean)

- `X`:

  Rollcall data matrix

- `clusters`:

  List of cluster assignments

- `clustering`:

  Final clustering dataframe

## Methods

### Public methods

- [`Clustering$new()`](#method-Clustering-initialize)

- [`Clustering$initialize_clusters()`](#method-Clustering-initialize_clusters)

- [`Clustering$iterate_clustering()`](#method-Clustering-iterate_clustering)

- [`Clustering$iteration()`](#method-Clustering-iteration)

- [`Clustering$get_distances()`](#method-Clustering-get_distances)

- [`Clustering$assign_clusters()`](#method-Clustering-assign_clusters)

- [`Clustering$create_clustering_dataframe()`](#method-Clustering-create_clustering_dataframe)

- [`Clustering$reclassify_legislators()`](#method-Clustering-reclassify_legislators)

- [`Clustering$clone()`](#method-Clustering-clone)

------------------------------------------------------------------------

### `Clustering$new()`

Initialize Clustering object

#### Usage

    Clustering$new(rollcalls, N = 1, pivot = NULL)

#### Arguments

- `rollcalls`:

  Data frame with rollcall data

- `N`:

  Integer, distance metric (1 or 2)

- `pivot`:

  Character, pivot legislator name

------------------------------------------------------------------------

### `Clustering$initialize_clusters()`

Initialize clusters with farthest legislators

#### Usage

    Clustering$initialize_clusters(pivot)

#### Arguments

- `pivot`:

  Character, pivot legislator name

------------------------------------------------------------------------

### `Clustering$iterate_clustering()`

Iterate clustering assignment

#### Usage

    Clustering$iterate_clustering()

------------------------------------------------------------------------

### `Clustering$iteration()`

Single clustering iteration

#### Usage

    Clustering$iteration()

------------------------------------------------------------------------

### `Clustering$get_distances()`

Calculate distances between tensors

#### Usage

    Clustering$get_distances(tensor1, tensor2)

#### Arguments

- `tensor1`:

  First data matrix

- `tensor2`:

  Second data matrix

------------------------------------------------------------------------

### `Clustering$assign_clusters()`

Assign left and right clusters based on pivot

#### Usage

    Clustering$assign_clusters(pivot)

#### Arguments

- `pivot`:

  Character, pivot legislator name

------------------------------------------------------------------------

### `Clustering$create_clustering_dataframe()`

Create clustering dataframe

#### Usage

    Clustering$create_clustering_dataframe()

------------------------------------------------------------------------

### `Clustering$reclassify_legislators()`

Reclassify legislators to optimal clusters

#### Usage

    Clustering$reclassify_legislators()

------------------------------------------------------------------------

### `Clustering$clone()`

The objects of this class are cloneable with this method.

#### Usage

    Clustering$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
