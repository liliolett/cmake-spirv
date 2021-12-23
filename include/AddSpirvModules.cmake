cmake_minimum_required(VERSION 3.19)


# Adds custom commands to compile a number of shader source files to
# SPIR-V using glslc and bundles them into a custom target.
function(add_spirv_modules TARGET_NAME)
	# Find glslc
	find_package(Vulkan REQUIRED glslc)

	# Parse arguments
	cmake_parse_arguments(PARSE_ARGV 1 "ARG"
			""
			"SOURCE_DIR;BINARY_DIR"
			"SOURCES;OPTIONS"
			)

	# Adjust arguments / provide defaults
	if(NOT DEFINED ARG_SOURCE_DIR)
		set(ARG_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR})
	elseif(NOT IS_ABSOLUTE ${ARG_SOURCE_DIR})
		set(ARG_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/${ARG_SOURCE_DIR})
		endif()

	if(NOT DEFINED ARG_BINARY_DIR)
		set(ARG_BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR})
	elseif(NOT IS_ABSOLUTE ${ARG_BINARY_DIR})
		set(ARG_BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR}/${ARG_BINARY_DIR})
		endif()

	# Define custom compilation commands
	foreach(FILE IN LISTS ARG_SOURCES)
		set(SOURCE_FILE ${ARG_SOURCE_DIR}/${FILE})
		set(BINARY_FILE ${ARG_BINARY_DIR}/${FILE}.spv)
		file(RELATIVE_PATH BIN_FILE_REL_PATH ${CMAKE_BINARY_DIR} ${BINARY_FILE})

		add_custom_command(
				OUTPUT          ${BINARY_FILE}
				COMMAND         ${Vulkan_GLSLC_EXECUTABLE}
						${SOURCE_FILE}
						-o ${BINARY_FILE}
						${ARG_OPTIONS}
				MAIN_DEPENDENCY ${SOURCE_FILE}
				COMMENT         "Building SPIR-V shader ${BIN_FILE_REL_PATH}"
				VERBATIM
				COMMAND_EXPAND_LISTS
				)

		list(APPEND BINARIES ${BINARY_FILE})
		endforeach()

	# Create target consisting of all compilation results
	add_custom_target(${TARGET_NAME} DEPENDS ${BINARIES})

	endfunction()
