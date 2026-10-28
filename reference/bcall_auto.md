# B-Call Analysis with Automatic Clustering

PRINCIPLE 1: User provides only rollcall data. This function
automatically clusters legislators into two groups and runs B-Call
analysis.

## Usage

``` r
bcall_auto(
  rollcall,
  distance_method = 1,
  pivot = NULL,
  threshold = 0.1,
  verbose = TRUE
)
```

## Arguments

- rollcall:

  data.frame with rollcall voting data (legislators as rows, votes as
  columns) Values: 1 (Yes), -1 (No), 0 (Abstention), NA (Absent)

- distance_method:

  Integer, distance metric for clustering (1 = Manhattan, 2 = Euclidean)

- pivot:

  Character, optional pivot legislator name. The pivot's cluster is
  labelled 'right' and its side of d1 is positive. If NULL, the cluster
  that contains the first row of `rollcall` is labelled 'right', its
  legislator with the highest participation becomes the pivot, and a
  warning is given because the sign of d1 is then arbitrary.

- threshold:

  Numeric, minimum participation threshold (0.0-1.0)

- verbose:

  Logical, whether to print progress messages

## Value

A list of class `bcall_result`, printed briefly, with: - results:
data.frame with d1, d2, auto_cluster for each legislator - bcall_object:
BCall R6 object - clustering_object: Clustering R6 object - metadata:
Analysis metadata

## Examples

``` r
# Create sample rollcall data
rollcall <- data.frame(
  vote1 = c(1, -1, 1, -1, 1, -1),
  vote2 = c(1, -1, 1, -1, 1, -1),
  vote3 = c(-1, 1, -1, 1, -1, 1),
  vote4 = c(1, 1, -1, -1, 1, -1),
  row.names = paste0("Legislator_", LETTERS[1:6])
)

# Run automatic clustering analysis
results <- bcall_auto(rollcall, distance_method = 1, pivot = "Legislator_B",
                      threshold = 0.1, verbose = FALSE)

# View results
head(results$results)
#>                      d1        d2   legislator auto_cluster
#> Legislator_A -0.9128709 0.0000000 Legislator_A         left
#> Legislator_B  0.4564355 0.9128709 Legislator_B        right
#> Legislator_C -0.4564355 0.9128709 Legislator_C         left
#> Legislator_D  0.9128709 0.0000000 Legislator_D        right
#> Legislator_E -0.9128709 0.0000000 Legislator_E         left
#> Legislator_F  0.9128709 0.0000000 Legislator_F        right

# Visualize
# \donttest{
plot_bcall_analysis(results)

if (requireNamespace("plotly", quietly = TRUE)) {
  plot_bcall_analysis_interactive(results)
}

{"x":{"visdat":{"1b2457ed1c89":["function () ","plotlyVisDat"]},"cur_data":"1b2457ed1c89","attrs":{"1b2457ed1c89":{"x":{},"y":{},"text":{},"hovertemplate":"%{text}<extra><\/extra>","mode":"markers","marker":{"size":8},"color":{},"alpha_stroke":1,"sizes":[10,100],"spans":[1,20],"type":"scatter"}},"layout":{"margin":{"b":40,"l":60,"t":25,"r":10},"title":"B-Call Analysis: Legislative Voting","xaxis":{"domain":[0,1],"automargin":true,"title":"d1 (Ideological Position)"},"yaxis":{"domain":[0,1],"automargin":true,"title":"d2 (Political Cohesion)"},"coloraxis":{"colorbar":{"title":"Auto_cluster"}},"hovermode":"closest","showlegend":true},"source":"A","config":{"modeBarButtonsToAdd":["hoverclosest","hovercompare"],"showSendToCloud":false},"data":[{"x":[-0.9128709291752769,-0.45643546458763845,-0.9128709291752769],"y":[0,0.9128709291752769,0],"text":["Legislator: Legislator_A<br>d1: -0.913<br>d2: 0<br>Auto_cluster: left","Legislator: Legislator_C<br>d1: -0.456<br>d2: 0.913<br>Auto_cluster: left","Legislator: Legislator_E<br>d1: -0.913<br>d2: 0<br>Auto_cluster: left"],"hovertemplate":["%{text}<extra><\/extra>","%{text}<extra><\/extra>","%{text}<extra><\/extra>"],"mode":"markers","marker":{"color":"rgba(102,194,165,1)","size":8,"line":{"color":"rgba(102,194,165,1)"}},"type":"scatter","name":"left","textfont":{"color":"rgba(102,194,165,1)"},"error_y":{"color":"rgba(102,194,165,1)"},"error_x":{"color":"rgba(102,194,165,1)"},"line":{"color":"rgba(102,194,165,1)"},"xaxis":"x","yaxis":"y","frame":null},{"x":[0.45643546458763845,0.9128709291752769,0.9128709291752769],"y":[0.9128709291752769,0,0],"text":["Legislator: Legislator_B<br>d1: 0.456<br>d2: 0.913<br>Auto_cluster: right","Legislator: Legislator_D<br>d1: 0.913<br>d2: 0<br>Auto_cluster: right","Legislator: Legislator_F<br>d1: 0.913<br>d2: 0<br>Auto_cluster: right"],"hovertemplate":["%{text}<extra><\/extra>","%{text}<extra><\/extra>","%{text}<extra><\/extra>"],"mode":"markers","marker":{"color":"rgba(141,160,203,1)","size":8,"line":{"color":"rgba(141,160,203,1)"}},"type":"scatter","name":"right","textfont":{"color":"rgba(141,160,203,1)"},"error_y":{"color":"rgba(141,160,203,1)"},"error_x":{"color":"rgba(141,160,203,1)"},"line":{"color":"rgba(141,160,203,1)"},"xaxis":"x","yaxis":"y","frame":null}],"highlight":{"on":"plotly_click","persistent":false,"dynamic":false,"selectize":false,"opacityDim":0.20000000000000001,"selected":{"opacity":1},"debounce":0},"shinyEvents":["plotly_hover","plotly_click","plotly_selected","plotly_relayout","plotly_brushed","plotly_brushing","plotly_clickannotation","plotly_doubleclick","plotly_deselect","plotly_afterplot","plotly_sunburstclick"],"base_url":"https://plot.ly"},"evals":[],"jsHooks":[]}# }
```
