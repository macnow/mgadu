/* GObject - GLib Type, Object, Parameter and Signal Library
 * Copyright (C) 2000-2001 Red Hat, Inc.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General
 * Public License along with this library; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place, Suite 330,
 * Boston, MA 02111-1307, USA.
 */
#include 	"gobjectalias.h"
#include	"gclosure.h"

#include	"gvalue.h"
#include	<string.h>


/* FIXME: need caching allocators
 */

#define	CLOSURE_MAX_REF_COUNT		((1 << 15) - 1)
#define	CLOSURE_MAX_N_GUARDS		((1 << 1) - 1)
#define	CLOSURE_MAX_N_FNOTIFIERS	((1 << 2) - 1)
#define	CLOSURE_MAX_N_INOTIFIERS	((1 << 8) - 1)
#define	CLOSURE_N_MFUNCS(cl)		((cl)->meta_marshal + \
                                         ((cl)->n_guards << 1L))
/* same as G_CLOSURE_N_NOTIFIERS() (keep in sync) */
#define	CLOSURE_N_NOTIFIERS(cl)		(CLOSURE_N_MFUNCS (cl) + \
                                         (cl)->n_fnotifiers + \
                                         (cl)->n_inotifiers)
enum {
  FNOTIFY,
  INOTIFY,
  PRE_NOTIFY,
  POST_NOTIFY
};


/* --- functions --- */
GClosure*
g_closure_new_simple (guint           sizeof_closure,
		      gpointer        data)
{
  GClosure *closure;

  g_return_val_if_fail (sizeof_closure >= sizeof (GClosure), NULL);

  closure = g_malloc (sizeof_closure);
  closure->ref_count = 1;
  closure->meta_marshal = 0;
  closure->n_guards = 0;
  closure->n_fnotifiers = 0;
  closure->n_inotifiers = 0;
  closure->in_inotify = FALSE;
  closure->floating = TRUE;
  closure->derivative_flag = 0;
  closure->in_marshal = FALSE;
  closure->is_invalid = FALSE;
  closure->marshal = NULL;
  closure->data = data;
  closure->notifiers = NULL;
  memset (G_STRUCT_MEMBER_P (closure, sizeof (*closure)), 0, sizeof_closure - sizeof (*closure));

  return closure;
}

static inline void
closure_invoke_notifiers (GClosure *closure,
			  guint     notify_type)
{
  /* notifier layout:
   *     meta_marshal  n_guards    n_guards     n_fnotif.  n_inotifiers
   * ->[[meta_marshal][pre_guards][post_guards][fnotifiers][inotifiers]]
   *
   * CLOSURE_N_MFUNCS(cl)    = meta_marshal + n_guards + n_guards;
   * CLOSURE_N_NOTIFIERS(cl) = CLOSURE_N_MFUNCS(cl) + n_fnotifiers + n_inotifiers
   *
   * constrains/catches:
   * - closure->notifiers may be reloacted during callback
   * - closure->n_fnotifiers and closure->n_inotifiers may change during callback
   * - i.e. callbacks can be removed/added during invocation
   * - have to prepare for callback removal during invocation (->marshal & ->data)
   * - have to distinguish (->marshal & ->data) for INOTIFY/FNOTIFY (->in_inotify)
   * + closure->n_guards is const during PRE_NOTIFY & POST_NOTIFY
   * + closure->meta_marshal is const for all cases
   * + none of the callbacks can cause recursion
   * + closure->n_inotifiers is const 0 during FNOTIFY
   */
  switch (notify_type)
    {
      GClosureNotifyData *ndata;
      guint i, offs;
    case FNOTIFY:
      while (closure->n_fnotifiers)
	{
	  register guint n = --closure->n_fnotifiers;

	  ndata = closure->notifiers + CLOSURE_N_MFUNCS (closure) + n;
	  closure->marshal = (GClosureMarshal) ndata->notify;
	  closure->data = ndata->data;
	  ndata->notify (ndata->data, closure);
	}
      closure->marshal = NULL;
      closure->data = NULL;
      break;
    case INOTIFY:
      closure->in_inotify = TRUE;
      while (closure->n_inotifiers)
	{
          register guint n = --closure->n_inotifiers;

	  ndata = closure->notifiers + CLOSURE_N_MFUNCS (closure) + closure->n_fnotifiers + n;
	  closure->marshal = (GClosureMarshal) ndata->notify;
	  closure->data = ndata->data;
	  ndata->notify (ndata->data, closure);
	}
      closure->marshal = NULL;
      closure->data = NULL;
      closure->in_inotify = FALSE;
      break;
    case PRE_NOTIFY:
      i = closure->n_guards;
      offs = closure->meta_marshal;
      while (i--)
	{
	  ndata = closure->notifiers + offs + i;
	  ndata->notify (ndata->data, closure);
	}
      break;
    case POST_NOTIFY:
      i = closure->n_guards;
      offs = closure->meta_marshal + i;
      while (i--)
	{
	  ndata = closure->notifiers + offs + i;
	  ndata->notify (ndata->data, closure);
	}
      break;
    }
}

void
g_closure_set_meta_marshal (GClosure       *closure,
			    gpointer        marshal_data,
			    GClosureMarshal meta_marshal)
{
  GClosureNotifyData *notifiers;
  guint n;

  g_return_if_fail (closure != NULL);
  g_return_if_fail (meta_marshal != NULL);
  g_return_if_fail (closure->is_invalid == FALSE);
  g_return_if_fail (closure->in_marshal == FALSE);
  g_return_if_fail (closure->meta_marshal == 0);

  n = CLOSURE_N_NOTIFIERS (closure);
  notifiers = closure->notifiers;
  closure->notifiers = g_renew (GClosureNotifyData, NULL, CLOSURE_N_NOTIFIERS (closure) + 1);
  if (notifiers)
    {
      /* usually the meta marshal will be setup right after creation, so the
       * g_memmove() should be rare-case scenario
       */
      g_memmove (closure->notifiers + 1, notifiers, CLOSURE_N_NOTIFIERS (closure) * sizeof (notifiers[0]));
      g_free (notifiers);
    }
  closure->notifiers[0].data = marshal_data;
  closure->notifiers[0].notify = (GClosureNotify) meta_marshal;
  closure->meta_marshal = 1;
}

void
g_closure_add_marshal_guards (GClosure      *closure,
			      gpointer       pre_marshal_data,
			      GClosureNotify pre_marshal_notify,
			      gpointer       post_marshal_data,
			      GClosureNotify post_marshal_notify)
{
  guint i;

  g_return_if_fail (closure != NULL);
  g_return_if_fail (pre_marshal_notify != NULL);
  g_return_if_fail (post_marshal_notify != NULL);
  g_return_if_fail (closure->is_invalid == FALSE);
  g_return_if_fail (closure->in_marshal == FALSE);
  g_return_if_fail (closure->n_guards < CLOSURE_MAX_N_GUARDS);

  closure->notifiers = g_renew (GClosureNotifyData, closure->notifiers, CLOSURE_N_NOTIFIERS (closure) + 2);
  if (closure->n_inotifiers)
    closure->notifiers[(CLOSURE_N_MFUNCS (closure) +
			closure->n_fnotifiers +
			closure->n_inotifiers + 1)] = closure->notifiers[(CLOSURE_N_MFUNCS (closure) +
									  closure->n_fnotifiers + 0)];
  if (closure->n_inotifiers > 1)
    closure->notifiers[(CLOSURE_N_MFUNCS (closure) +
			closure->n_fnotifiers +
			closure->n_inotifiers)] = closure->notifiers[(CLOSURE_N_MFUNCS (closure) +
								      closure->n_fnotifiers + 1)];
  if (closure->n_fnotifiers)
    closure->notifiers[(CLOSURE_N_MFUNCS (closure) +
			closure->n_fnotifiers + 1)] = closure->notifiers[CLOSURE_N_MFUNCS (closure) + 0];
  if (closure->n_fnotifiers > 1)
    closure->notifiers[(CLOSURE_N_MFUNCS (closure) +
			closure->n_fnotifiers)] = closure->notifiers[CLOSURE_N_MFUNCS (closure) + 1];
  if (closure->n_guards)
    closure->notifiers[(closure->meta_marshal +
			closure->n_guards +
			closure->n_guards + 1)] = closure->notifiers[closure->meta_marshal + closure->n_guards];
  i = closure->n_guards++;
  closure->notifiers[closure->meta_marshal + i].data = pre_marshal_data;
  closure->notifiers[closure->meta_marshal + i].notify = pre_marshal_notify;
  closure->notifiers[closure->meta_marshal + i + 1].data = post_marshal_data;
  closure->notifiers[closure->meta_marshal + i + 1].notify = post_marshal_notify;
}

void
g_closure_add_finalize_notifier (GClosure      *closure,
				 gpointer       notify_data,
				 GClosureNotify notify_func)
{
  guint i;

  g_return_if_fail (closure != NULL);
  g_return_if_fail (notify_func != NULL);
  g_return_if_fail (closure->n_fnotifiers < CLOSURE_MAX_N_FNOTIFIERS);

  closure->notifiers = g_renew (GClosureNotifyData, closure->notifiers, CLOSURE_N_NOTIFIERS (closure) + 1);
  if (closure->n_inotifiers)
    closure->notifiers[(CLOSURE_N_MFUNCS (closure) +
			closure->n_fnotifiers +
			closure->n_inotifiers)] = closure->notifiers[(CLOSURE_N_MFUNCS (closure) +
								      closure->n_fnotifiers + 0)];
  i = CLOSURE_N_MFUNCS (closure) + closure->n_fnotifiers++;
  closure->notifiers[i].data = notify_data;
  closure->notifiers[i].notify = notify_func;
}

void
g_closure_add_invalidate_notifier (GClosure      *closure,
				   gpointer       notify_data,
				   GClosureNotify notify_func)
{
  guint i;

  g_return_if_fail (closure != NULL);
  g_return_if_fail (notify_func != NULL);
  g_return_if_fail (closure->is_invalid == FALSE);
  g_return_if_fail (closure->n_inotifiers < CLOSURE_MAX_N_INOTIFIERS);

  closure->notifiers = g_renew (GClosureNotifyData, closure->notifiers, CLOSURE_N_NOTIFIERS (closure) + 1);
  i = CLOSURE_N_MFUNCS (closure) + closure->n_fnotifiers + closure->n_inotifiers++;
  closure->notifiers[i].data = notify_data;
  closure->notifiers[i].notify = notify_func;
}

static inline gboolean
closure_try_remove_inotify (GClosure       *closure,
			    gpointer       notify_data,
			    GClosureNotify notify_func)
{
  GClosureNotifyData *ndata, *nlast;

  nlast = closure->notifiers + CLOSURE_N_NOTIFIERS (closure) - 1;
  for (ndata = nlast + 1 - closure->n_inotifiers; ndata <= nlast; ndata++)
    if (ndata->notify == notify_func && ndata->data == notify_data)
      {
	closure->n_inotifiers -= 1;
	if (ndata < nlast)
	  *ndata = *nlast;

	return TRUE;
      }
  return FALSE;
}

static inline gboolean
closure_try_remove_fnotify (GClosure       *closure,
			    gpointer       notify_data,
			    GClosureNotify notify_func)
{
  GClosureNotifyData *ndata, *nlast;

  nlast = closure->notifiers + CLOSURE_N_NOTIFIERS (closure) - closure->n_inotifiers - 1;
  for (ndata = nlast + 1 - closure->n_fnotifiers; ndata <= nlast; ndata++)
    if (ndata->notify == notify_func && ndata->data == notify_data)
      {
	closure->n_fnotifiers -= 1;
	if (ndata < nlast)
	  *ndata = *nlast;
	if (closure->n_inotifiers)
	  closure->notifiers[(CLOSURE_N_MFUNCS (closure) +
			      closure->n_fnotifiers)] = closure->notifiers[(CLOSURE_N_MFUNCS (closure) +
									    closure->n_fnotifiers +
									    closure->n_inotifiers)];
	return TRUE;
      }
  return FALSE;
}

GClosure*
g_closure_ref (GClosure *closure)
{
  g_return_val_if_fail (closure != NULL, NULL);
  g_return_val_if_fail (closure->ref_count > 0, NULL);
  g_return_val_if_fail (closure->ref_count < CLOSURE_MAX_REF_COUNT, NULL);

  closure->ref_count += 1;

  return closure;
}

void
g_closure_invalidate (GClosure *closure)
{
  g_return_if_fail (closure != NULL);

  if (!closure->is_invalid)
    {
      closure->ref_count += 1;	/* preserve floating flag */
      closure->is_invalid = TRUE;
      closure_invoke_notifiers (closure, INOTIFY);
      g_closure_unref (closure);
    }
}

void
g_closure_unref (GClosure *closure)
{
  g_return_if_fail (closure != NULL);
  g_return_if_fail (closure->ref_count > 0);

  if (closure->ref_count == 1)	/* last unref, invalidate first */
    g_closure_invalidate (closure);

  closure->ref_count -= 1;

  if (closure->ref_count == 0)
    {
      closure_invoke_notifiers (closure, FNOTIFY);
      g_free (closure->notifiers);
      g_free (closure);
    }
}

void
g_closure_sink (GClosure *closure)
{
  g_return_if_fail (closure != NULL);
  g_return_if_fail (closure->ref_count > 0);

  /* floating is basically a kludge to avoid creating closures
   * with a ref_count of 0. so the intial ref_count a closure has
   * is unowned. with invoking g_closure_sink() code may
   * indicate that it takes over that intiial ref_count.
   */
  if (closure->floating)
    {
      closure->floating = FALSE;
      if (closure->ref_count > 1)
	closure->ref_count -= 1;
      else
	g_closure_unref (closure);
    }
}

void
g_closure_remove_invalidate_notifier (GClosure      *closure,
				      gpointer       notify_data,
				      GClosureNotify notify_func)
{
  g_return_if_fail (closure != NULL);
  g_return_if_fail (notify_func != NULL);

  if (closure->is_invalid && closure->in_inotify && /* account removal of notify_func() while its called */
      ((gpointer) closure->marshal) == ((gpointer) notify_func) && closure->data == notify_data)
    closure->marshal = NULL;
  else if (!closure_try_remove_inotify (closure, notify_data, notify_func))
    g_warning (G_STRLOC ": unable to remove uninstalled invalidation notifier: %p (%p)",
	       notify_func, notify_data);
}

void
g_closure_remove_finalize_notifier (GClosure      *closure,
				    gpointer       notify_data,
				    GClosureNotify notify_func)
{
  g_return_if_fail (closure != NULL);
  g_return_if_fail (notify_func != NULL);

  if (closure->is_invalid && !closure->in_inotify && /* account removal of notify_func() while its called */
      ((gpointer) closure->marshal) == ((gpointer) notify_func) && closure->data == notify_data)
    closure->marshal = NULL;
  else if (!closure_try_remove_fnotify (closure, notify_data, notify_func))
    g_warning (G_STRLOC ": unable to remove uninstalled finalization notifier: %p (%p)",
               notify_func, notify_data);
}

void
g_closure_invoke (GClosure       *closure,
		  GValue /*out*/ *return_value,
		  guint           n_param_values,
		  const GValue   *param_values,
		  gpointer        invocation_hint)
{
  g_return_if_fail (closure != NULL);

  if (!closure->is_invalid)
    {
      GClosureMarshal marshal;
      gpointer marshal_data;
      gboolean in_marshal = closure->in_marshal;

      g_return_if_fail (closure->marshal || closure->meta_marshal);

      closure->ref_count += 1;	/* preserve floating flag */
      closure->in_marshal = TRUE;
      if (closure->meta_marshal)
	{
	  marshal_data = closure->notifiers[0].data;
	  marshal = (GClosureMarshal) closure->notifiers[0].notify;
	}
      else
	{
	  marshal_data = NULL;
	  marshal = closure->marshal;
	}
      if (!in_marshal)
	closure_invoke_notifiers (closure, PRE_NOTIFY);
      marshal (closure,
	       return_value,
	       n_param_values, param_values,
	       invocation_hint,
	       marshal_data);
      if (!in_marshal)
	closure_invoke_notifiers (closure, POST_NOTIFY);
      closure->in_marshal = in_marshal;
      g_closure_unref (closure);
    }
}

void
g_closure_set_marshal (GClosure       *closure,
		       GClosureMarshal marshal)
{
  g_return_if_fail (closure != NULL);
  g_return_if_fail (marshal != NULL);

  if (closure->marshal && closure->marshal != marshal)
    g_warning ("attempt to override closure->marshal (%p) with new marshal (%p)",
	       closure->marshal, marshal);
  else
    closure->marshal = marshal;
}

GClosure*
g_cclosure_new (GCallback      callback_func,
		gpointer       user_data,
		GClosureNotify destroy_data)
{
  GClosure *closure;
  
  g_return_val_if_fail (callback_func != NULL, NULL);
  
  closure = g_closure_new_simple (sizeof (GCClosure), user_data);
  if (destroy_data)
    g_closure_add_finalize_notifier (closure, user_data, destroy_data);
  ((GCClosure*) closure)->callback = (gpointer) callback_func;
  
  return closure;
}

GClosure*
g_cclosure_new_swap (GCallback      callback_func,
		     gpointer       user_data,
		     GClosureNotify destroy_data)
{
  GClosure *closure;
  
  g_return_val_if_fail (callback_func != NULL, NULL);
  
  closure = g_closure_new_simple (sizeof (GCClosure), user_data);
  if (destroy_data)
    g_closure_add_finalize_notifier (closure, user_data, destroy_data);
  ((GCClosure*) closure)->callback = (gpointer) callback_func;
  closure->derivative_flag = TRUE;
  
  return closure;
}

static void
g_type_class_meta_marshal (GClosure       *closure,
			   GValue /*out*/ *return_value,
			   guint           n_param_values,
			   const GValue   *param_values,
			   gpointer        invocation_hint,
			   gpointer        marshal_data)
{
  GTypeClass *class;
  gpointer callback;
  /* GType itype = (GType) closure->data; */
  guint offset = GPOINTER_TO_UINT (marshal_data);
  
  class = G_TYPE_INSTANCE_GET_CLASS (g_value_peek_pointer (param_values + 0), itype, GTypeClass);
  callback = G_STRUCT_MEMBER (gpointer, class, offset);
  if (callback)
    closure->marshal (closure,
		      return_value,
		      n_param_values, param_values,
		      invocation_hint,
		      callback);
}

static void
g_type_iface_meta_marshal (GClosure       *closure,
			   GValue /*out*/ *return_value,
			   guint           n_param_values,
			   const GValue   *param_values,
			   gpointer        invocation_hint,
			   gpointer        marshal_data)
{
  GTypeClass *class;
  gpointer callback;
  GType itype = (GType) closure->data;
  guint offset = GPOINTER_TO_UINT (marshal_data);
  
  class = G_TYPE_INSTANCE_GET_INTERFACE (g_value_peek_pointer (param_values + 0), itype, GTypeClass);
  callback = G_STRUCT_MEMBER (gpointer, class, offset);
  if (callback)
    closure->marshal (closure,
		      return_value,
		      n_param_values, param_values,
		      invocation_hint,
		      callback);
}

GClosure*
g_signal_type_cclosure_new (GType    itype,
			    guint    struct_offset)
{
  GClosure *closure;
  
  g_return_val_if_fail (G_TYPE_IS_CLASSED (itype) || G_TYPE_IS_INTERFACE (itype), NULL);
  g_return_val_if_fail (struct_offset >= sizeof (GTypeClass), NULL);
  
  closure = g_closure_new_simple (sizeof (GClosure), (gpointer) itype);
  if (G_TYPE_IS_INTERFACE (itype))
    g_closure_set_meta_marshal (closure, GUINT_TO_POINTER (struct_offset), g_type_iface_meta_marshal);
  else
    g_closure_set_meta_marshal (closure, GUINT_TO_POINTER (struct_offset), g_type_class_meta_marshal);
  
  return closure;
}
