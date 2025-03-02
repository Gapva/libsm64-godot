class_name SM64SurfaceObjectsHandler
extends Node


const FPS_30_DELTA := 1.0/30.0

## SM64Handler instance
@export var sm64_handler: SM64Handler
## Group name that contains the MeshInstance3D that are part of the scene's surface objects
@export var surface_objects_group := &"libsm64_surface_objects"

var _surface_objects_ids: Array[int] = []
var _surface_objects_refs: Array[MeshInstance3D] = []
var _time_since_last_tick := 0.0
var _default_surface_properties := SM64SurfaceProperties.new()


func _physics_process(delta: float) -> void:
	_time_since_last_tick += delta
	if _time_since_last_tick < FPS_30_DELTA:
		return
	_time_since_last_tick -= FPS_30_DELTA

	_update_surface_objects()


func _update_surface_objects() -> void:
	for i in range(_surface_objects_ids.size()):
		var id := _surface_objects_ids[i]
		var position := _surface_objects_refs[i].global_transform.origin
		var rotation := _surface_objects_refs[i].rotation
		sm64_handler.surface_object_move(id, position, rotation)


## Load MeshInstance3D into the SM64Handler instance
func load_surface_object(mesh_instance: MeshInstance3D) -> void:
	var mesh_faces := mesh_instance.get_mesh().get_faces()
	var position := mesh_instance.global_position
	var rotation := mesh_instance.global_rotation

	var surface_properties := _find_surface_properties(mesh_instance)
	var surface_properties_array: Array[SM64SurfaceProperties] = []
	surface_properties_array.resize(mesh_faces.size() / 3)
	surface_properties_array.fill(surface_properties)

	var surface_object_id := sm64_handler.surface_object_create(mesh_faces, position, rotation, surface_properties_array)

	_surface_objects_ids.push_back(surface_object_id)
	_surface_objects_refs.push_back(mesh_instance)

	# Clean up automaticaly if MeshInstance3D is removed from tree or freed
	mesh_instance.tree_exiting.connect(delete_surface_object.bind(mesh_instance), CONNECT_ONE_SHOT)


## Load all MeshInstance3D in surface_objects_group into the SM64Handler instance
func load_all_surface_objects() -> void:
	for node in get_tree().get_nodes_in_group(surface_objects_group):
		var mesh_instance := node as MeshInstance3D
		if not mesh_instance:
			push_warning("Non MeshInstance3D in %s group" % surface_objects_group)
			continue
		load_surface_object(mesh_instance)


## Delete MeshInstance3D from the SM64Handler instance if present
func delete_surface_object(mesh_instance: MeshInstance3D) -> void:
	var index := _surface_objects_refs.find(mesh_instance)
	if index == -1:
		return

	var id := _surface_objects_ids[index]
	sm64_handler.surface_object_delete(id)
	_surface_objects_refs.remove_at(index)
	_surface_objects_ids.remove_at(index)


## Delete all MeshInstance3D from the SM64Handler instance
func delete_all_surface_objects() -> void:
	for id in _surface_objects_ids:
		sm64_handler.surface_object_delete(id)

	_surface_objects_refs.clear()
	_surface_objects_ids.clear()


func _find_surface_properties(node: Node) -> SM64SurfaceProperties:
	for child in node.get_children():
		if child is SM64SurfacePropertiesComponent:
			return child.surface_properties

	return _default_surface_properties
