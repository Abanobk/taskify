import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:graphview/GraphView.dart';
import 'package:taskify/config/colors.dart';
import 'package:taskify/utils/widgets/custom_text.dart';
import '../../data/repositories/Project/project_repo.dart';
import '../../routes/routes.dart';
import '../../utils/widgets/back_arrow.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MindMapNode {
  final String id;
  final String topic;
  final String? link;
  final bool isRoot;
  final int level;
  final List<MindMapNode> children;

  MindMapNode({
    required this.id,
    required this.topic,
    this.link,
    this.isRoot = false,
    this.level = 0,
    this.children = const [],
  });

  factory MindMapNode.fromJson(Map<String, dynamic> json) {
    return MindMapNode(
      id: json['id'] as String,
      topic: json['topic'] as String,
      link: json['link'] as String?,
      isRoot: json['isroot'] == true,
      level: json['level'] as int? ?? 0,
      children: (json['children'] as List?)
              ?.map((child) =>
                  MindMapNode.fromJson(child as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

// Then update your MindMapScreen class to use this data

class MindMapScreen extends StatefulWidget {
  final int projectId;
  MindMapScreen({Key? key, required this.projectId}) : super(key: key);

  @override
  _MindMapScreenState createState() => _MindMapScreenState();
}

class _MindMapScreenState extends State<MindMapScreen> {
  final Graph graph = Graph()..isTree = true;
  final builder = BuchheimWalkerConfiguration();
  final FruchtermanReingoldAlgorithm fruchterman =
      FruchtermanReingoldAlgorithm();
  bool useTreeLayout = true;
  bool isLoading = true;
  final Set<String> expandedNodes = {};
  final Map<String, Node> nodeMap = {};

  // Replace treeData with parsed mind map
  late MindMapNode rootNode;

  @override
  void initState() {
    super.initState();
    getMindMap();
    // // Parse JSON string (paste your data here or load it dynamically)
    // const jsonString = '''{ "id":"project_4","topic":"fdf",... }'''; // your full JSON here
    // final jsonMap = jsonDecode(jsonString);
    // rootNode = MindMapNode.fromJson(jsonMap);

    // auto expand root
    //   builder
    //     ..siblingSeparation = 40
    //     ..levelSeparation = 100
    //     ..subtreeSeparation = 50
    //     ..orientation = BuchheimWalkerConfiguration.ORIENTATION_TOP_BOTTOM;
    //
    //   _buildGraph();
  }

  getMindMap() async {
    setState(() => isLoading = true); // start loading

    try {
      Map<String, dynamic> result =
          await ProjectRepo().getProjectMindMap(id: widget.projectId);
      rootNode = MindMapNode.fromJson(result['original']['data']);
      expandedNodes.add(rootNode.id); // Expand root node
      _buildGraph();
    } catch (e) {
      print("Error loading mind map: $e");
      // You can show an error widget or snackbar here
    }

    setState(() => isLoading = false); // stop loading
  }

  void _buildGraph() {
    graph.nodes.clear();
    graph.edges.clear();
    nodeMap.clear();

    void addNode(MindMapNode current, [MindMapNode? parent]) {
      Node node = nodeMap[current.id] ??= Node.Id(current.id);
      graph.addNode(node);

      if (parent != null) {
        final parentNode = nodeMap[parent.id]!;
        graph.addEdge(parentNode, node);
      }

      if (expandedNodes.contains(current.id)) {
        for (var child in current.children) {
          addNode(child, current);
        }
      }
    }

    addNode(rootNode);
    setState(() {});
  }

  Widget _createNodeWidget(MindMapNode nodeData, bool isExpanded) {
    final bool isRootNode = nodeData.isRoot; // Check if it's the root

    return GestureDetector(
      onTap: () {
        if (nodeData.children.isNotEmpty) {
          setState(() {
            if (expandedNodes.contains(nodeData.id)) {
              expandedNodes.remove(nodeData.id);
            } else {
              expandedNodes.add(nodeData.id);
            }
            _buildGraph();
          });
        } else if (nodeData.link != null) {
          // Handle URL logic here
        }
      },
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          // 👇 This is your actual node container
          Container(
            padding: EdgeInsets.all(5.w),
            decoration: BoxDecoration(
              color: isRootNode
                  ? AppColors.primary.withValues(alpha: 0.3)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.primary),
            ),
            child: CustomText(
              text: nodeData.topic,
              size: 15.sp,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.textClrChange,
            ),
          ),
          const SizedBox(height: 0), // spacing between container and circle
          // 👇 This is the connector circle
          nodeData.children.isNotEmpty
              ? Positioned(
                  bottom: -4,
                  left: 0,
                  right: 0,
                  child: Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                )
              : SizedBox(),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.backGroundColor,

      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            child: BackArrow(
              onTap: () => router.pop(),
              title: "Mind Map",
            ),
          ),
          SizedBox(
            height: 50.h,
          ),
          isLoading
              ? const SpinKitFadingCircle(
                  color: AppColors.primary,
                  size: 40.0,
                )
              : Expanded(
                  child: InteractiveViewer(
                    constrained: false,
                    boundaryMargin: const EdgeInsets.all(100),
                    minScale: 0.01,
                    maxScale: 5.6,
                    child: GraphView(
                      animated: true,
                      paint: Paint()
                        ..color = Colors.orangeAccent
                        ..strokeWidth = 1,
                      graph: graph,
                      algorithm: useTreeLayout
                          ? BuchheimWalkerAlgorithm(
                              builder, TreeEdgeRenderer(builder))
                          : fruchterman,
                      builder: (Node node) {
                        final nodeId = node.key!.value as String;
                        final nodeData = _findNodeById(rootNode, nodeId)!;
                        final isExpanded = expandedNodes.contains(nodeId) &&
                            nodeData.children.isNotEmpty;
                        return _createNodeWidget(nodeData, isExpanded);
                      },
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  MindMapNode? _findNodeById(MindMapNode node, String id) {
    if (node.id == id) return node;
    for (var child in node.children) {
      final found = _findNodeById(child, id);
      if (found != null) return found;
    }
    return null;
  }
}
