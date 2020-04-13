/************************************

NumPy <--> OpenCV typemaps

Source: https://github.com/neingeist/python-exercises/blob/master/okapi-typemaps.i


************************************/


%{
#define SWIG_FILE_WITH_INIT

#if ((PY_MAJOR_VERSION == 2 && PY_MINOR_VERSION > 6) || \
     (PY_MAJOR_VERSION == 3 && PY_MINOR_VERSION > 0) || \
     (PY_MAJOR_VERSION > 3))
#define CAPSULES_SUPPORTED
#endif

#ifndef NPY_ARRAY_C_CONTIGUOUS
 #define NPY_ARRAY_C_CONTIGUOUS NPY_C_CONTIGUOUS
 #define PyArray_SetBaseObject(arr, x) (PyArray_BASE(arr) = (x))
#endif
%}

%include "numpy_old.i"
%init %{
import_array();
%}

%fragment("OKAPI_Fragments", "header",
          fragment="NumPy_Fragments")
{
    // convert NumPy type to OpenCV type
    int numpy_type_to_mat_type(PyArrayObject *array, int channels)
    {
        switch (array_type(array)) {
            case NPY_BYTE:   return CV_MAKETYPE(CV_8S, channels);
            case NPY_UBYTE:  return CV_MAKETYPE(CV_8U, channels);
            case NPY_SHORT:  return CV_MAKETYPE(CV_16S, channels);
            case NPY_USHORT: return CV_MAKETYPE(CV_16U, channels);
            case NPY_INT:    return CV_MAKETYPE(CV_32S, channels);
            //case NPY_UINT:  // does not exist
            //case NPY_LONG:  // does not exist
            //case NPY_ULONG: // does not exist
            case NPY_FLOAT:  return CV_MAKETYPE(CV_32F, channels);
            case NPY_DOUBLE: return CV_MAKETYPE(CV_64F, channels);
            default:
                PyErr_Format(PyExc_TypeError,
                             "Unsupported datatype: %s.",
                             typecode_string(array_type(array)));
        }
        return -1;
    }

    // convert OpenCV type to NumPy type
    int mat_type_to_numpy_type(int type)
    {
        // convert numpy type to CV type
        switch (CV_MAT_DEPTH(type)) {
            case CV_8S:  return NPY_BYTE;
            case CV_8U:  return NPY_UBYTE;
            case CV_16S: return NPY_SHORT;
            case CV_16U: return NPY_USHORT;
            case CV_32S: return NPY_INT;
            //case NPY_UINT:  // does not exist
            //case NPY_LONG:  // does not exist
            //case NPY_ULONG: // does not exist
            case CV_32F: return NPY_FLOAT;
            case CV_64F: return NPY_DOUBLE;
            default:
                PyErr_Format(PyExc_TypeError,
                             "Unsupported OpenCV datatype: %d (depth: %d).",
                             type, CV_MAT_DEPTH(type));
        }
        return -1;
    }

    void delete_mat(void *ptr)
    {
        // printf("deleting underlying mat at %p\n", ptr);
        cv::Mat *m = static_cast< cv::Mat* >(ptr);
        assert (m != NULL);
        delete m;
    }

%#ifdef CAPSULES_SUPPORTED
    void delete_mat_capsule(PyObject *obj)
    {
        // printf("deleting underlying mat at %p\n", ptr);
        cv::Mat *m = static_cast< cv::Mat* >(PyCapsule_GetPointer(obj, NULL));
        assert (m != NULL);
        delete m;
    }
%#endif

	

	cv::Scalar* array_to_scalar(PyObject* input)
	{
		PyArrayObject* array = obj_to_array_no_conversion(input, NPY_NOTYPE);
        if (array == NULL) {
            // error message is set by obj_to_array_no_conversion
            return NULL;
        }
        
        // creates 4-element integer array ToDo: diff. convert data types
        size_t size = array_size(array, 0);
        size_t step = array->strides[0];
        int data[4] = {0, 0, 0, 0};
        for(size_t i=0, j=0; i<size*step; i+=step,j++){
        	data[j] = (unsigned char)array_data(array)[i];
        }

		return new cv::Scalar(data[0], data[1], data[2], data[3]);
	}
	
	cv::Size* array_to_size(PyObject* input)
    {
        PyArrayObject* array = obj_to_array_no_conversion(input, NPY_NOTYPE);
        if (array == NULL) {
            // error message is set by obj_to_array_no_conversion
            return NULL;
        }
        
        // creates 4-element integer array ToDo: diff. convert data types
        size_t size = array_size(array, 0);
        size_t step = array->strides[0];
        int data[4] = {0, 0, 0, 0};
        for(size_t i=0, j=0; i<size*step; i+=step,j++){
            data[j] = (unsigned char)array_data(array)[i];
        }

        return new cv::Size(data[0], data[1]);
    }

    cv::Mat* array_to_mat(PyObject* input)
    {
        PyArrayObject* array = obj_to_array_no_conversion(input, NPY_NOTYPE);
        if (array == NULL) {
            // error message is set by obj_to_array_no_conversion
            return NULL;
        }

        // check if array has 2 or 3 dimensions
        int ndims = array_numdims(array);
        int channels, type;
        if (ndims == 2)
            channels = 1;
        else if (ndims == 3) {
            channels = array_size(array, 2);
            // check number of channels
            if (channels > 4) {
                PyErr_Format(PyExc_TypeError,
                             "Array can have a maximum of 4 channels.  Input as %d.", channels);
                return NULL;
            }
        }
        else {
            PyErr_Format(PyExc_TypeError,
                         "Array must be 2- or 3-dimensional.  Input is %d-dimensional.", ndims);
            return NULL;
        }

        // convert NumPy type to OpenCV type
        if ((type = numpy_type_to_mat_type(array, channels)) == -1)
            return NULL;

        // check that array is in C order
        for (int i = 0; i < ndims-1; ++i) {
            if (PyArray_STRIDE(array, i) < PyArray_STRIDE(array, i+1)) {
                PyErr_Format(PyExc_TypeError,
                             "Array is not in C order: stride of dim %d: %ld < stride of dim %d: %ld",
                             i, PyArray_STRIDE(array, i), i+1, PyArray_STRIDE(array, i+1));
                return NULL;
            }
        }

        // use stride of first dimension as stepsize
        // and check strides of other dimensions
        int step = ((PyArrayObject *)array)->strides[0];
        if (PyArray_STRIDE(array, 1) != channels * PyArray_ITEMSIZE(array)) {
            PyErr_Format(PyExc_TypeError,
                         "Array cannot have strides in other than 1st dimension (rows). Dim 2: %ld vs %d",
                         PyArray_STRIDE(array, 1), channels * PyArray_ITEMSIZE(array));
            return NULL;
        }

        // create new view onto the data
        return new cv::Mat(array_size(array, 0), array_size(array, 1), type, array_data(array), step);
    }

    PyObject* mat_to_array(const cv::Mat& mat)
    {
        // handle empty mat
        if (mat.empty()) {
            npy_intp dims[1] = { 0 };
            int type = mat_type_to_numpy_type(mat.type());
            PyObject* array = PyArray_EMPTY(1, dims, type, 0);
            return array;
        }

        npy_intp dims[3]    = { mat.rows, mat.cols, mat.channels() };
        npy_intp strides[3] = { (npy_intp)mat.step, (npy_intp)mat.elemSize(), (npy_intp)mat.elemSize1()};
        int ndims = (mat.channels() > 1) ? 3 : 2; 
        int type = mat_type_to_numpy_type(mat.type());
        int flags = NPY_WRITEABLE;
        if (mat.isContinuous())
            flags |= NPY_C_CONTIGUOUS;
        PyObject* array = PyArray_New(&PyArray_Type, ndims, dims, type, 
                                      strides, mat.data, 0, flags, NULL);
        return array;
    }
    
    PyObject* point2f_to_array(cv::Point2f* point)
    {
        npy_intp dims = 2;
        npy_intp strides[1] = { 1 };
        int flags = NPY_WRITEABLE;
        float *data = new float[2];
        data[0] = point->x;
        data[1] = point->y;
        PyObject* array = PyArray_SimpleNewFromData(1, &dims, NPY_FLOAT, data);
        return array;
    }

    PyObject* point3f_to_array(cv::Point3f* point)
    {
        npy_intp dims = 3;
        npy_intp strides[1] = { 1 };
        int flags = NPY_WRITEABLE;
        float *data = new float[3];
        data[0] = point->x;
        data[1] = point->y;
        data[2] = point->z;
        PyObject* array = PyArray_SimpleNewFromData(1, &dims, NPY_FLOAT, data);
        return array;
    }

    PyObject* point3fvec_to_array(std::vector<cv::Point3f>* v)
    {
        npy_intp dims = 3;
        npy_intp strides[1] = { 1 };
        int flags = NPY_WRITEABLE;
        float *data = new float[3*v->size()];
        for(size_t i=0; i<v->size(); i++){
            data[i*3] = v->at(i).x;
            data[i*3+1] = v->at(i).y;
            data[i*3+2] = v->at(i).z;
        }
        PyObject* array = PyArray_SimpleNewFromData(v->size(), &dims, NPY_FLOAT, data);
        return array;
    }
}

///////////////////////////////////////
/// const cv::Mat&
///////////////////////////////////////
%typecheck(SWIG_TYPECHECK_POINTER,
        fragment="OKAPI_Fragments")
   const cv::Mat&
{
    $1 = is_array($input) || PySequence_Check($input);
}
%typemap(in, numinputs=1,
         fragment="OKAPI_Fragments")
   const cv::Mat&
{
    $1 = array_to_mat($input);
    if ($1 == NULL)
        SWIG_fail;
}

%typemap(freearg,
         fragment="OKAPI_Fragments")
   const cv::Mat&
{
    if ($1 != NULL)
        delete $1;
}
%typemap(argout,
         fragment="OKAPI_Fragments")
   const cv::Mat&
{
}

%typecheck(SWIG_TYPECHECK_POINTER,
        fragment="OKAPI_Fragments")
   cv::Mat const &
{
    $1 = true;//is_array($input) || PySequence_Check($input);
}
%typemap(in, numinputs=1,
         fragment="OKAPI_Fragments")
   cv::Mat const &
{
    $1 = array_to_mat($input);
    if ($1 == NULL)
        SWIG_fail;
}

///////////////////////////////////////
/// cv::Mat
///////////////////////////////////////
%typecheck(SWIG_TYPECHECK_POINTER,
        fragment="OKAPI_Fragments")
   cv::Mat
{
    $1 = is_array($input) || PySequence_Check($input);
}
%typemap(in, numinputs=1,
         fragment="OKAPI_Fragments")
   cv::Mat
   (cv::Mat* mat)
{
    mat = array_to_mat($input);
    if (mat == NULL)
        SWIG_fail;
    $1 = *mat;
}
%typemap(freearg,
         fragment="OKAPI_Fragments")
   cv::Mat
{
    if (mat$argnum != NULL)
        delete mat$argnum;
}
%typemap(argout,
         fragment="OKAPI_Fragments")
   cv::Mat
{
}

///////////////////////////////////////
/// cv::Mat*
///////////////////////////////////////
%typecheck(SWIG_TYPECHECK_POINTER,
        fragment="OKAPI_Fragments")
   cv::Mat*
{
    $1 = is_array($input) || PySequence_Check($input);
}
%typemap(in, numinputs=1,
         fragment="OKAPI_Fragments")
   cv::Mat*
   (uchar* data_ptr)
{
    $1 = array_to_mat($input);
    if ($1 == NULL)
        SWIG_fail;
    // save dataptr to check whether it changed
    data_ptr = $1->data;
}
%typemap(freearg,
         fragment="OKAPI_Fragments")
   cv::Mat*
{
    if ($1 != NULL)
        delete $1;
}
%typemap(argout,
         fragment="OKAPI_Fragments")
   cv::Mat*
{
    // check if the underlying data changed
    if (data_ptr$argnum != $1->data) {
        // TODO don't fail if we can reallocate the underlying memory
        // (not always possible due to the way NumPy does reference counting)
        PyErr_Format(PyExc_RuntimeError,
                     "Underlying data changed. Please make sure that the "
                     "input data is of correct size and type: %d %d %d",
                     $1->rows, $1->cols, $1->type());
        SWIG_fail;
    }
}

///////////////////////////////////////
/// cv::Mat&
///////////////////////////////////////
%typecheck(SWIG_TYPECHECK_POINTER,
        fragment="OKAPI_Fragments")
   cv::Mat&
{
    $1 = is_array($input) || PySequence_Check($input);
}
%typemap(in, numinputs=1,
         fragment="OKAPI_Fragments")
   cv::Mat &
   (uchar* data_ptr)
{
    $1 = array_to_mat($input);
    if ($1 == NULL)
        SWIG_fail;
    // save dataptr to check whether it changed
    data_ptr = $1->data;
}
%typemap(freearg,
         fragment="OKAPI_Fragments")
   cv::Mat&
{
    if ($1 != NULL)
        delete $1;
}
%typemap(argout,
         fragment="OKAPI_Fragments")
   cv::Mat&
{
    // check if the underlying data changed
    if (data_ptr$argnum != $1->data) {
        // TODO don't fail if we can reallocate the underlying memory
        // (not always possible due to the way NumPy does reference counting)
        PyErr_Format(PyExc_RuntimeError,
                     "Underlying data changed. Please make sure that the "
                     "input data is of correct size and type: %d %d %d",
                     $1->rows, $1->cols, $1->type());
        SWIG_fail;
    }
}

///////////////////////////////////////
/// return cv::Mat
///////////////////////////////////////
%typemap(out,
         fragment="NumPy_Fragments")
   cv::Mat
{
    PyObject* array = mat_to_array($1);
    if (array == NULL)
        SWIG_fail;

    // add a reference to the underlying cv::Mat so
    // that the memory is not freed before the NumPy array
    // is released or reassigned
    cv::Mat *m = new cv::Mat($1);
    // printf("created new mat object at %p\n", m);
    %#ifdef CAPSULES_SUPPORTED
    PyArray_BASE(array) = PyCapsule_New(m, NULL, delete_mat_capsule);
    %#else
    PyArray_BASE(array) = PyCObject_FromVoidPtr(m, delete_mat);
    %#endif

    $result = array;
}

%typemap(out,
         fragment="NumPy_Fragments")
   const cv::Mat&
{
    PyObject* array = mat_to_array(*$1);
    if (array == NULL)
        SWIG_fail;

    // add a reference to the underlying cv::Mat so
    // that the memory is not freed before the NumPy array
    // is released or reassigned
    cv::Mat *m = new cv::Mat(*$1);
    // printf("created new mat object at %p\n", m);
    %#ifdef CAPSULES_SUPPORTED
    PyArray_BASE(array) = PyCapsule_New(m, NULL, delete_mat_capsule);
    %#else
    PyArray_BASE(array) = PyCObject_FromVoidPtr(m, delete_mat);
    %#endif

    $result = array;
}

///////////////////////////////////////
// vector<cv::Mat>
///////////////////////////////////////
%define %vector_typemap(T)
%typecheck(SWIG_TYPECHECK_POINTER,
           fragment="OKAPI_Fragments")
    const std::vector<T> &
{
    $1 = PySequence_Check($input);
}
%typemap(in,
         fragment="OKAPI_Fragments")
    const std::vector<T> &
    (std::vector<T*> relvec)
{
    if (!PySequence_Check($input)) {
        printf("NO SEQUENCE\n");
        SWIG_fail;
    }

    Py_ssize_t length = PySequence_Size($input);
    $1 = new std::vector< cv::Mat >(length);
    for (Py_ssize_t ii = 0; ii < length; ++ii) {
        cv::Mat *tmp = array_to_mat(PySequence_GetItem($input, ii));
        if (tmp == NULL) {
            printf("%ld no array\n", ii);
            SWIG_fail;
        }
        $1->at(ii) = *tmp;
        relvec.push_back(tmp);
    }
}
%typemap(freearg,
         fragment="OKAPI_Fragments")
   const std::vector<T> &
{
    if ($1 != NULL)
        delete $1;
    for (size_t ii = 0; ii < relvec$argnum.size(); ++ii)
        delete relvec$argnum[ii];
}
%enddef


///////////////////////////////////////
// okapi::bstring
///////////////////////////////////////
%typemap(out) okapi::bstring
{
    $result = PyByteArray_FromStringAndSize((const char*) &$1[0], $1.size());
}


///////////////////////////////////////
// buffers
///////////////////////////////////////
%typemap(in) (const void *buffer, std::size_t buffer_size) {
   if (PyByteArray_Check($input)) {
       $1 = (void *) PyByteArray_AsString($input);
       $2 = PyByteArray_Size($input);
   }
%#if PY_MAJOR_VERSION < 3
   else if (PyString_Check($input)) {
       $1 = (void *) PyString_AsString($input);
       $2 = PyString_Size($input);
   }
%#endif
   else {
       PyErr_SetString(PyExc_ValueError, "Expecting a bytearray");
       return NULL;
   }
}
%typemap(typecheck) (const void *buffer, std::size_t buffer_size) {
    $1 = (PyByteArray_Check($input) || PyString_Check($input)) ? 1 : 0;
}


///////////////////////////////////////
// boost::filesystem::path
///////////////////////////////////////
%typecheck(SWIG_TYPECHECK_POINTER)
    const boost::filesystem::path &
{
    $1 = PyUnicode_Check($input) || PyBytes_Check($input);
}
%typemap(in) const boost::filesystem::path &
{
    if (PyUnicode_Check($input))
    {
        PyObject *bytes = PyUnicode_AsEncodedString($input, Py_FileSystemDefaultEncoding, "surrogateescape");
        $1 = new boost::filesystem::path(PyBytes_AsString(bytes));
        Py_CLEAR(bytes);
    }
    else if (PyBytes_Check($input))
    {
        $1 = new boost::filesystem::path(PyBytes_AsString($input));
    }
}
%typemap(freearg) const boost::filesystem::path
{
    delete $1;
}


///////////////////////////////////////
/// const cv::Scalar
///////////////////////////////////////

%typecheck(SWIG_TYPECHECK_POINTER,
        fragment="OKAPI_Fragments")
   cv::Scalar
{
    $1 = is_array($input) || PySequence_Check($input);
}


%typemap(in, numinputs=1,
         fragment="OKAPI_Fragments")
   cv::Scalar
{
    $1 = *array_to_scalar($input);
    if (&$1 == NULL)
        SWIG_fail;
}

///////////////////////////////////////
/// const cv::Size
///////////////////////////////////////

%typecheck(SWIG_TYPECHECK_POINTER,
        fragment="OKAPI_Fragments")
   cv::Size
{
    $1 = is_array($input) || PySequence_Check($input);
}


%typemap(in, numinputs=1,
         fragment="OKAPI_Fragments")
   cv::Size
{
    $1 = *array_to_size($input);
    if (&$1 == NULL)
        SWIG_fail;
}

///////////////////////////////////////
/// return cv::Point2f *
///////////////////////////////////////

%typemap(out,
         fragment="OKAPI_Fragments")
cv::Point2f
{
    PyObject* array = point2f_to_array(&$1);
    if (array == NULL)
        SWIG_fail;

    $result = array;
}

///////////////////////////////////////
/// return cv::Point3f *
///////////////////////////////////////

%typemap(out,
         fragment="OKAPI_Fragments")
cv::Point3f
{
    PyObject* array = point3f_to_array(&$1);
    if (array == NULL)
        SWIG_fail;

    $result = array;
}

// %typemap(out,
//          fragment="OKAPI_Fragments")
// std::vector< cv::Point3f >::value_type *
// {
//     PyObject* array = point3f_to_array($1);
//     if (array == NULL)
//         SWIG_fail;
//
//     $result = array;
// }


// %typemap(out,
//          fragment="OKAPI_Fragments")
// cv::Point3f *
// {
//     PyObject* array = point3f_to_array($1);
//     if (array == NULL)
//         SWIG_fail;
//
//     $result = array;
// }